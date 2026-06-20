"use strict";

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {defineSecret, defineString} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const nodemailer = require("nodemailer");

const ownerEmail = defineString("OWNER_EMAIL");
const gmailUser = defineSecret("GMAIL_USER");
const gmailAppPassword = defineSecret("GMAIL_APP_PASSWORD");

const buildLeadEmail = (lead) => ({
  replyTo: lead.email,
  subject: "New Lead Received",
  text: [
    "Name:",
    lead.name ?? "",
    "",
    "Email:",
    lead.email ?? "",
    "",
    "Phone:",
    lead.phone ?? "",
    "",
    "Business:",
    lead.businessName ?? "",
    "",
    "Message:",
    lead.message ?? "",
  ].join("\n"),
});

exports.notifyOwnerOfNewLead = onDocumentCreated(
  {
    document: "contact_leads/{leadId}",
    secrets: [gmailUser, gmailAppPassword],
    region: "asia-south1",
    retry: true,
  },
  async (event) => {
    const lead = event.data?.data();
    if (!lead) {
      logger.warn("Lead event contained no document data", {
        leadId: event.params.leadId,
      });
      return;
    }

    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: gmailUser.value(),
        pass: gmailAppPassword.value(),
      },
    });

    const email = buildLeadEmail(lead);

    await transporter.sendMail({
      from: `Groome Leads <${gmailUser.value()}>`,
      to: ownerEmail.value(),
      ...email,
    });

    logger.info("New lead notification sent", {
      leadId: event.params.leadId,
    });
  },
);

exports._test = {
  buildLeadEmail,
};
