"use strict";

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const nodemailer = require("nodemailer");

const contactSenderEmail = "support@groome.net";
const contactRecipientEmail = "Maanyam@groome.net";
const gmailAppPassword = defineSecret("GMAIL_APP_PASSWORD");

const cleanValue = (value) => (typeof value === "string" ? value.trim() : "");

const escapeHtml = (value) =>
  cleanValue(value).replace(/[&<>"']/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    "\"": "&quot;",
    "'": "&#39;",
  })[character]);

const buildLeadEmail = (lead) => {
  const name = cleanValue(lead.name);
  const email = cleanValue(lead.email).toLowerCase();
  const phone = cleanValue(lead.phone);
  const businessName = cleanValue(lead.businessName);
  const message = cleanValue(lead.message);

  return {
    replyTo: email,
    subject: "New user contact request",
    text: [
      "The new user needs to contact you.",
      "",
      "Name:",
      name,
      "",
      "Email:",
      email,
      "",
      "Phone no:",
      phone,
      "",
      "Business name:",
      businessName,
      "",
      "Message:",
      message,
      "",
      "Groome",
    ].join("\n"),
    html: [
      "<p>The new user needs to contact you.</p>",
      `<p><strong>Name:</strong><br>${escapeHtml(name)}</p>`,
      `<p><strong>Email:</strong><br>${escapeHtml(email)}</p>`,
      `<p><strong>Phone no:</strong><br>${escapeHtml(phone)}</p>`,
      `<p><strong>Business name:</strong><br>${escapeHtml(businessName)}</p>`,
      `<p><strong>Message:</strong><br>${escapeHtml(message)}</p>`,
      "<p>Groome</p>",
    ].join(""),
  };
};

const createLeadNotificationHandler = ({
  createTransport = nodemailer.createTransport,
  getGmailAppPassword = () => gmailAppPassword.value(),
  log = logger,
} = {}) => async (event) => {
  const lead = event.data?.data();
  if (!lead) {
    log.warn("Lead event contained no document data", {
      leadId: event.params.leadId,
    });
    return;
  }

  const transporter = createTransport({
    service: "gmail",
    auth: {
      user: contactSenderEmail,
      pass: getGmailAppPassword(),
    },
  });

  const email = buildLeadEmail(lead);

  await transporter.sendMail({
    from: `Groome Leads <${contactSenderEmail}>`,
    to: contactRecipientEmail,
    ...email,
  });

  log.info("New lead notification sent", {
    leadId: event.params.leadId,
  });
};

exports.notifyOwnerOfNewLead = onDocumentCreated(
  {
    document: "contact_leads/{leadId}",
    secrets: [gmailAppPassword],
    region: "asia-south1",
    retry: true,
  },
  createLeadNotificationHandler(),
);

exports._test = {
  buildLeadEmail,
  createLeadNotificationHandler,
};
