"use strict";

const assert = require("node:assert/strict");
const test = require("node:test");

const {_test} = require("./index");

test("builds the Contact Us lead email payload", () => {
  const email = _test.buildLeadEmail({
    name: "Aarav Mehta",
    email: "aarav@example.com",
    phone: "+91 98765 43210",
    businessName: "Glow Studio",
    message: "I want to bring my salon online with Groome.",
  });

  assert.equal(email.replyTo, "aarav@example.com");
  assert.equal(email.subject, "New user contact request");
  assert.match(email.text, /^The new user needs to contact you\./);
  assert.match(email.text, /Name:\nAarav Mehta/);
  assert.match(email.text, /Email:\naarav@example\.com/);
  assert.match(email.text, /Phone no:\n\+91 98765 43210/);
  assert.match(email.text, /Business name:\nGlow Studio/);
  assert.match(
    email.text,
    /Message:\nI want to bring my salon online with Groome\./,
  );
  assert.match(email.text, /\nGroome$/);
  assert.match(
    email.html,
    /<p>The new user needs to contact you\.<\/p>/,
  );
  assert.match(email.html, /<strong>Name:<\/strong><br>Aarav Mehta/);
  assert.match(
    email.html,
    /<strong>Business name:<\/strong><br>Glow Studio/,
  );
});

test("sends the Contact Us lead email through Gmail", async () => {
  let transportConfig;
  let sentEmail;
  const infoLogs = [];
  const handler = _test.createLeadNotificationHandler({
    getGmailAppPassword: () => "app-password",
    createTransport: (config) => {
      transportConfig = config;
      return {
        sendMail: async (email) => {
          sentEmail = email;
        },
      };
    },
    log: {
      info: (...args) => infoLogs.push(args),
      warn: () => {},
    },
  });

  await handler({
    params: {leadId: "lead-123"},
    data: {
      data: () => ({
        name: "Aarav Mehta",
        email: "aarav@example.com",
        phone: "+91 98765 43210",
        businessName: "Glow Studio",
        message: "I want to bring my salon online with Groome.",
      }),
    },
  });

  assert.deepEqual(transportConfig, {
    service: "gmail",
    auth: {
      user: "support@groome.net",
      pass: "app-password",
    },
  });
  assert.equal(sentEmail.from, "Groome Leads <support@groome.net>");
  assert.equal(sentEmail.to, "Maanyam@groome.net");
  assert.equal(sentEmail.replyTo, "aarav@example.com");
  assert.equal(sentEmail.subject, "New user contact request");
  assert.match(sentEmail.text, /^The new user needs to contact you\./);
  assert.match(sentEmail.text, /Business name:\nGlow Studio/);
  assert.match(sentEmail.text, /\nGroome$/);
  assert.match(sentEmail.html, /<strong>Email:<\/strong><br>aarav@example.com/);
  assert.deepEqual(infoLogs, [
    ["New lead notification sent", {leadId: "lead-123"}],
  ]);
});
