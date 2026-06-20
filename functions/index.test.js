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
  assert.equal(email.subject, "New Lead Received");
  assert.match(email.text, /Name:\nAarav Mehta/);
  assert.match(email.text, /Email:\naarav@example\.com/);
  assert.match(email.text, /Phone:\n\+91 98765 43210/);
  assert.match(email.text, /Business:\nGlow Studio/);
  assert.match(
    email.text,
    /Message:\nI want to bring my salon online with Groome\./,
  );
});
