const js = require("@eslint/js");

module.exports = [
  js.configs.recommended,
  {
    languageOptions: {ecmaVersion: 2022, sourceType: "commonjs"},
    rules: {
      "indent": ["error", 2],
      "max-len": ["error", {code: 100, ignoreUrls: true}],
      "quotes": ["error", "double", {allowTemplateLiterals: true}],
      "semi": ["error", "always"],
    },
  },
];
