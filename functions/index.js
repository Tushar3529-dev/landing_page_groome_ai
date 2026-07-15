"use strict";

const admin = require("firebase-admin");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const nodemailer = require("nodemailer");
const {getAuth} = require("firebase-admin/auth");
const {FieldValue, getFirestore} = require("firebase-admin/firestore");

admin.initializeApp();

const contactSenderEmail = "support@groome.net";
const contactRecipientEmail = "Maanyam@groome.net";
const gmailAppPassword = defineSecret("GMAIL_APP_PASSWORD");
const bootstrapAdminKey = defineSecret("BOOTSTRAP_ADMIN_KEY");
const region = "asia-south1";

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
    region,
    retry: true,
  },
  createLeadNotificationHandler(),
);

const requireSuperAdmin = (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login is required.");
  }

  if (request.auth.token.role !== "superAdmin") {
    throw new HttpsError(
      "permission-denied",
      "Only Super Admin can perform this action.",
    );
  }
};

const cleanDashboardText = (value, field, {min = 1, max = 160} = {}) => {
  const cleaned = cleanValue(value);
  if (cleaned.length < min || cleaned.length > max) {
    throw new HttpsError(
      "invalid-argument",
      `${field} must be between ${min} and ${max} characters.`,
    );
  }
  return cleaned;
};

const cleanDashboardEmail = (value) => {
  const email = cleanDashboardText(value, "Email", {min: 5, max: 254})
    .toLowerCase();
  if (!email.includes("@")) {
    throw new HttpsError("invalid-argument", "Enter a valid email.");
  }
  return email;
};

const cleanDashboardPassword = (value) =>
  cleanDashboardText(value, "Password", {min: 8, max: 128});

const dashboardUserData = ({name, email, role, subscriptionActive, salonName}) => ({
  name,
  email,
  role,
  subscriptionActive,
  primarySalonName: salonName,
  updatedAt: FieldValue.serverTimestamp(),
});

const createDashboardAdminHandler = async (request) => {
  requireSuperAdmin(request);

  const name = cleanDashboardText(request.data?.name, "Name", {
    min: 2,
    max: 120,
  });
  const email = cleanDashboardEmail(request.data?.email);
  const password = cleanDashboardPassword(request.data?.password);
  const salonName = cleanDashboardText(request.data?.salonName, "Salon name", {
    min: 2,
    max: 160,
  });

  const auth = getAuth();
  const db = getFirestore();
  let userRecord;

  try {
    userRecord = await auth.createUser({
      email,
      password,
      displayName: name,
    });
  } catch (error) {
    if (error.code === "auth/email-already-exists") {
      throw new HttpsError(
        "already-exists",
        "An account already exists for this email.",
      );
    }

    if (error.code === "auth/invalid-password") {
      throw new HttpsError(
        "invalid-argument",
        "Password must be at least 8 characters.",
      );
    }

    throw error;
  }

  await auth.setCustomUserClaims(userRecord.uid, {role: "salonAdmin"});

  const userRef = db.collection("dashboard_users").doc(userRecord.uid);
  const salonRef = db.collection("salons").doc();
  const batch = db.batch();
  batch.set(userRef, {
    ...dashboardUserData({
      name,
      email,
      role: "salonAdmin",
      subscriptionActive: true,
      salonName,
    }),
    createdAt: FieldValue.serverTimestamp(),
  });
  batch.set(salonRef, {
    ownerUserId: userRecord.uid,
    name: salonName,
    locality: "New Delhi",
    address: "Add salon address",
    phone: "+91 00000 00000",
    email,
    about: "New salon onboarded by Super Admin.",
    openingTime: "10:00 AM",
    closingTime: "08:00 PM",
    acceptingBookings: true,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
  await batch.commit();

  return {userId: userRecord.uid, salonId: salonRef.id};
};

const setDashboardUserPasswordHandler = async (request) => {
  requireSuperAdmin(request);

  const userId = cleanDashboardText(request.data?.userId, "User id", {
    min: 8,
    max: 160,
  });
  const password = cleanDashboardPassword(request.data?.password);
  await getAuth().updateUser(userId, {password});
  return {userId};
};

const setDashboardSubscriptionHandler = async (request) => {
  requireSuperAdmin(request);

  const userId = cleanDashboardText(request.data?.userId, "User id", {
    min: 8,
    max: 160,
  });
  const subscriptionActive = request.data?.subscriptionActive;
  if (typeof subscriptionActive !== "boolean") {
    throw new HttpsError(
      "invalid-argument",
      "subscriptionActive must be true or false.",
    );
  }

  const userRef = getFirestore().collection("dashboard_users").doc(userId);
  const userSnapshot = await userRef.get();
  if (!userSnapshot.exists) {
    throw new HttpsError("not-found", "Dashboard user was not found.");
  }
  if (userSnapshot.data().role === "superAdmin") {
    throw new HttpsError(
      "invalid-argument",
      "Super Admin subscription cannot be stopped.",
    );
  }

  await userRef.update({
    subscriptionActive,
    updatedAt: FieldValue.serverTimestamp(),
  });
  return {userId, subscriptionActive};
};

const deleteRefsInBatches = async (refs) => {
  const db = getFirestore();
  for (let index = 0; index < refs.length; index += 400) {
    const batch = db.batch();
    for (const ref of refs.slice(index, index + 400)) {
      batch.delete(ref);
    }
    await batch.commit();
  }
};

const deleteDashboardUserHandler = async (request) => {
  requireSuperAdmin(request);

  const userId = cleanDashboardText(request.data?.userId, "User id", {
    min: 8,
    max: 160,
  });
  const db = getFirestore();
  const userRef = db.collection("dashboard_users").doc(userId);
  const userSnapshot = await userRef.get();
  if (!userSnapshot.exists) {
    return {deleted: false};
  }
  if (userSnapshot.data().role === "superAdmin") {
    throw new HttpsError("invalid-argument", "Super Admin cannot be deleted.");
  }

  const refsToDelete = [userRef];
  const salonSnapshot = await db
    .collection("salons")
    .where("ownerUserId", "==", userId)
    .get();
  const salonIds = [];
  for (const salon of salonSnapshot.docs) {
    refsToDelete.push(salon.ref);
    salonIds.push(salon.id);
  }

  for (const salonId of salonIds) {
    for (const collection of [
      "team_members",
      "services",
      "bookings",
      "clients",
    ]) {
      const snapshot = await db
        .collection(collection)
        .where("salonId", "==", salonId)
        .get();
      for (const doc of snapshot.docs) {
        refsToDelete.push(doc.ref);
      }
    }
  }

  await deleteRefsInBatches(refsToDelete);
  try {
    await getAuth().deleteUser(userId);
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
  }

  return {deleted: true};
};

const bootstrapSuperAdminHandler = async (request) => {
  const expectedKey = bootstrapAdminKey.value();
  if (!expectedKey || request.data?.bootstrapKey !== expectedKey) {
    throw new HttpsError(
      "permission-denied",
      "Bootstrap key is missing or invalid.",
    );
  }

  const name = cleanDashboardText(request.data?.name, "Name", {
    min: 2,
    max: 120,
  });
  const email = cleanDashboardEmail(request.data?.email);
  const password = cleanDashboardPassword(request.data?.password);
  const auth = getAuth();
  let userRecord;

  try {
    userRecord = await auth.getUserByEmail(email);
    await auth.updateUser(userRecord.uid, {displayName: name, password});
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
    userRecord = await auth.createUser({email, password, displayName: name});
  }

  await auth.setCustomUserClaims(userRecord.uid, {role: "superAdmin"});
  await getFirestore().collection("dashboard_users").doc(userRecord.uid).set(
    {
      ...dashboardUserData({
        name,
        email,
        role: "superAdmin",
        subscriptionActive: true,
        salonName: "Groome HQ",
      }),
      createdAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return {userId: userRecord.uid};
};

exports.createDashboardAdmin = onCall(
  {region},
  createDashboardAdminHandler,
);

exports.setDashboardUserPassword = onCall(
  {region},
  setDashboardUserPasswordHandler,
);

exports.setDashboardSubscription = onCall(
  {region},
  setDashboardSubscriptionHandler,
);

exports.deleteDashboardUser = onCall(
  {region},
  deleteDashboardUserHandler,
);

exports.bootstrapSuperAdmin = onCall(
  {region, secrets: [bootstrapAdminKey]},
  bootstrapSuperAdminHandler,
);

exports._test = {
  buildLeadEmail,
  createLeadNotificationHandler,
  cleanDashboardEmail,
  cleanDashboardPassword,
};
