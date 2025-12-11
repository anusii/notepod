# Encryption Compliance

<!-- markdownlint-disable MD013 -->
<!-- markdownlint-disable MD034 -->
<!-- markdownlint-disable MD036 -->

*Part of General > App Information page*

This is the most useful Apple page guiding how to answer - see table:
https://developer.apple.com/help/app-store-connect/reference/app-information/export-compliance-documentation-for-encryption/

## App Encryption Document Questions

Question 1: App Purpose

Notepod is an app built with the Solid (Social Linked Data) specification. Using Notepod you can read, write, and share encrypted notes stored on your personal data vault (also called a Personal Online Datastore or Pod) hosted on a Solid Server.

Question 2: Type of Encryption

Select which encryption algorithms does your app implement:

- [ ] Encryption algorithms that are proprietary or not accepted as standard by international standard bodies (IEEE, IETF, ITU etc.) OR

- [x] Standard encryption algorithms instead of, or in addition to, using or accessing the encryption within Apple's operating system

Question 3: will we be releasing in France

*If yes, requires 'Declaration and application for authorization of operations relating to a means of cryptography' form submitted to and approved by French Govt to be uploaded to App Store. Form in folder release/france.

- [ ] Yes
- [ ] No

Our answer should be yes, but for App Review of early notepod versions can be No.

In which case, if we're only using standard encryption algorithms, then we don't need to provide any further documents to App Store for encryption compliance. And can submit for an Apple App Review to allow sharing of notepod install link to external testers, while we get the French encryption form approved.

Notes:

- notepod:
  - encryptVal/decryptVal - uses AES, defined in FIPS PUB 197: Advanced Encryption Standard and the ISO/IEC 18033-3: Block ciphers standard (Source: Wikipedia).
- solidpod:
  - decryptData/encryptData/encryptPrivateKey/decryptPrivateKey - AESMode.sic, AESMode.cbc (keys)
  - fast_rsa: RSA key pair generation
  - jwt_decoder: JwtDecoder.decode() - decoding of base64 encoding
