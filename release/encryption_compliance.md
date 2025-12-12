# Encryption Compliance

<!-- markdownlint-disable MD013 -->
<!-- markdownlint-disable MD034 -->
<!-- markdownlint-disable MD036 -->

*Part of General > App Information page*

This document analyses our use of encryption and answers the encryption compliance questions, excluding the French encryption declaration which has not yet been translated (or translation found).

## Legislation

### US

- Export Administration Regulations (EAR) - Encryption items fall under Category 5, Part 2 for Information Security. Reference: https://www.bis.gov/learn-support/encryption-controls

### France

- TBD

## notepod components using encryption

Note: all components are open source code.

- notepod:
  - encryptVal/decryptVal():
    - uses crypto: sha256()
    - uses encrypter_plus: Key(), Encrypter(AESmode.cbc) - AES is defined in FIPS PUB 197: Advanced Encryption Standard and the ISO/IEC 18033-3: Block ciphers standard
- solidpod:
  - decryptData/encryptData/encryptPrivateKey/decryptPrivateKey - AESMode.sic, AESMode.cbc (keys)
  - uses crypto: sha256(), sha224() hash functions
  - uses encrypter_plus: Key type, IV vector (base64), Encrypter(RSA()), RSAKeyParser(), Encrypter(), AESMode.cbc, AESMode.sic
  - uses fast_rsa: KeyPair, RSA.generate() - RSA key pair generation
  - uses pointycastle: RSAPublicKey, RSAPrivateKey types
- solid_auth:
  - uses fast_rsa: RSA.generate(), RSA.convert() - RSA key pair generation
  - uses pointycastle: SHA256Digest

  Related but not encryption:

  - base64 with jwt_decoder package

## Apple App Store Encryption Questions

Question 1: App Purpose

Notepod is an app built with the Solid (Social Linked Data) specification. Using Notepod you can read, write, and share encrypted notes stored on your personal data vault (also called a Personal Online Datastore or Pod) hosted on a Solid Server.

Question 2: Type of Encryption

Useful references:

1. https://developer.apple.com/help/app-store-connect/reference/app-information/export-compliance-documentation-for-encryption/, accessed 11 Dec 2025
2. US Dept of Commerce, Bureau of Industry & Security, Encryption Controls webpage https://www.bis.gov/learn-support/encryption-controls and Flowchart 1: Items Designed to Use Cryptography Including Items NOT controlled under Category 5 Part 2 of the EAR
https://www.bis.gov/media/documents/new-v2-flowchart1-july-2017.pdf, accessed 12 Dec 2025.

- Review of this information shows that if encryption algorithms used are accepted by international standards and/or open source, then no documents are required to be submitted to comply with US Export regulation of encryption, and only the  French encryption declaration must be uploaded if distributing to France. Determined from:
  - Ref 1: use of industry standard algorithm - Yes
  - Ref 2: use of publicly available source code - Yes

Select which encryption algorithms does your app implement:

- [ ] Encryption algorithms that are proprietary or not accepted as standard by international standard bodies (IEEE, IETF, ITU etc.) OR

- [x] Standard encryption algorithms instead of, or in addition to, using or accessing the encryption within Apple's operating system

Question 3: will we be releasing in France

*If yes, requires 'Declaration and application for authorization of operations relating to a means of cryptography' form submitted to and approved by French Govt to be uploaded to App Store. Form in folder release/france.

- [ ] Yes
- [x] No

Our answer should be yes, but for App Review of early notepod versions can be No.

In which case, if we're only using standard encryption algorithms, then we don't need to provide any further documents to App Store for encryption compliance. And can submit for an Apple App Review to allow sharing of notepod install link to external testers, while we get the French encryption form approved.
