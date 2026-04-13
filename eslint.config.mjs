import { defineConfig } from "eslint/config";
import globals from "globals";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

export default defineConfig([{
    extends: compat.extends("airbnb-base"),

    languageOptions: {
        globals: {
            ...globals.node,
            ...globals.jest,
            ...globals.browser,
            Atomics: "readonly",
            SharedArrayBuffer: "readonly",
            document: "readonly",
            describe: "readonly",
            test: "readonly",
            expect: "readonly",
            history: true,
            GOVUK: "readonly",
            dataLayer: "readonly",
            L: "readonly",
        },

        ecmaVersion: 2022,
        sourceType: "module",
    },

    rules: {
        semi: ["error", "always"],
        "no-use-before-define": 0,

        "max-len": ["error", {
            code: 200,
        }],

        quotes: ["error", "single"],
        "eol-last": 1,

        "no-multiple-empty-lines": ["error", {
            max: 1,
            maxEOF: 1,
        }],

        "import/prefer-default-export": 0,
        "import/no-named-as-default-member": 0,

        "no-unused-expressions": ["error", {
            allowTernary: true,
        }],

        "no-param-reassign": [2, {
            props: false,
        }],
    },
}]);