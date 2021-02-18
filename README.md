# USAATools
Tools for USAA Banking and Insurance clients

## USAA_OrganizeStatements.ps1

Organize downloaded USAA PDFs into a folder hierarchy like this:

* USAA Organized
   * 2019
   * 2020
      * Auto
      * Bank
         * 1234
         * 3456
         * 5678
      * Deposit Disclosure
      * Homeowners Insurance
      * Investments
         * 6543
         * 8621
         * 8249 
      * Life Insurance
      * Policy Bills
      * Renters Insurance
      * Umbrella Insurance
      * Valuable Personal Property
      * Wire Tranfers
   * 2021
* USAA Inbox Duplicates
* USAA Inbox - No Valid Doc Type

### Instructions:
1. Download *USAA_OrganizeStatements.ps1* to a new folder on your PC
1. Right-click *USAA_OrganizeStatements.ps1* to automatically create the folder "USAA Inbox"
1. Open https://www.usaa.com/inet/ent_edde/ViewMyDocuments/?0&wa_ref=pri_global_tools_addlservices_viewdocs
1. Click "Download" and choose "Check All", then scroll down and click Download
1. Move all downloaded PDFs to the "USAA Inbox" folder created in step 2 above
1. Again, right-click *USAA_OrganizeStatements.ps1* and re-run the PowerShell script.
1. All files in the folder "USAA Inbox" will be moved to one of these three folders:
   1. "USAA Organized"
   2. "USAA Inbox Duplicates"
   3. "USAA Inbox - No Valid Doc Type"
1. Files in "USAA Organized" will be organized into subfolders based on year, the type of PDF (Auto, Insurance, etc), and the account number.
