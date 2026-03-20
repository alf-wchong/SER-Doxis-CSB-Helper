> “Access rights … custom access rights and access rules.”
> ([UG_Doxis_CSB_14.3.0.pdf, p. 1117](https://services.sergroup.com/documentation/api/documentations/2/485/1482/WEBHELP/APP_CSB/topics/con_UserManual_Orgaadmin_Transport.html#con_ah1401986__ah1187221); same wording in [UG_Doxis_cubeDesigner_14.4.0.pdf, p. 1524](https://services.sergroup.com/documentation/api/documentations/23/501/1510/WEBHELP/APP_cubeDesigner/topics/con_Transport_Intro.html#con_bj1016660__welche_metadatenobjekte_knnen_transportiert_werde))

Here is the step-by-step way to make sure the needed rights are actually packaged.

1. In **cubeDesigner**, open **Miscellaneous > Tools > Transport**, then create a **package definition**.

   > “In the ribbon, click Miscellaneous > Tools > Transport.”
   > “You must specify a name for the package definition.”
   > (UG_Doxis_cubeDesigner_14.4.0.pdf, pp. [1525](https://services.sergroup.com/documentation/?#/view/PD_cubeDesigner/14.5.0/en-us/UG_Doxis_cubeDesigner/WEBHELP/APP_cubeDesigner/topics/tsk_Transport_DisplayDlgBox.html#tsk_bj1023989), [1527](https://services.sergroup.com/documentation/?#/view/PD_cubeDesigner/14.5.0/en-us/UG_Doxis_cubeDesigner/WEBHELP/APP_cubeDesigner/topics/tsk_Transport_CreatePackageDef.html#tsk_bj1023983))

2. In that package definition, select **every object whose rights need to move**, and do not forget manual dependencies.
   The guide is explicit that selective transport usually does **not** resolve dependencies for you:

   > “dependencies of metadata objects must be considered. This must generally be done manually.”
   > (UG_Doxis_cubeDesigner_14.4.0.pdf, p. [1528](https://services.sergroup.com/documentation/?#/view/PD_cubeDesigner/14.5.0/en-us/UG_Doxis_cubeDesigner/WEBHELP/APP_cubeDesigner/topics/tsk_Transport_CreatePackageDef.html#tsk_bj1023983))
   > This is one of the main ways rights get missed in a selective package.

3. In **Doxis Admin Client**, open **Utilities > Transport**, select that package definition, and run a **selective export**.
   The CSB guide says:

   > “A package definition created in Doxis cubeDesigner is required for selective exports.”
   > ([UG_Doxis_CSB_14.3.0.pdf, p. 1128](https://services.sergroup.com/documentation/#/view/PD_CSB_Short/14.3.0/en-us/UG_Doxis_CSB/WEBHELP/APP_CSB/topics/tsk_UserManual_Orgaadmin_Transport_ExportSelective.html))

4. On the **export** preferences, turn on the rights-related options you actually need.
   This is the most important export rule:

   > “with selective export, generally only those access rights that are granted to units, roles, and groups of the selected objects are transported. If this option is selected, user-specific access rights … are additionally exported.”
   > “Independent of this option, owner rights are always exported.”
   > ([UG_Doxis_CSB_14.3.0.pdf, p. 1129](https://services.sergroup.com/documentation/#/view/PD_CSB_Short/14.3.0/en-us/UG_Doxis_CSB/WEBHELP/APP_CSB/topics/tsk_UserManual_Orgaadmin_Transport_ExportSelective.html))
   > So:

   * enable **Export user-specific permissions** if you need user-level rights;
   * rely on owner rights being exported automatically;
   * enable **Export access rules** if access rules are part of what you need, because

     > “By default, access rules are ignored during the export.”
     > ([UG_Doxis_CSB_14.3.0.pdf, p. 1129](https://services.sergroup.com/documentation/#/view/PD_CSB_Short/14.3.0/en-us/UG_Doxis_CSB/WEBHELP/APP_CSB/topics/tsk_UserManual_Orgaadmin_Transport_ExportSelective.html))

5. On the **import** side, keep **Import rights and ownerships** enabled.
   This is the key import setting:

   > “access rights contained in the transport package are imported to the target organization. This option is selected by default.”
   > “The import of access rights can be disabled. In this case, new access rights are not defined…”
   > ([UG_Doxis_CSB_14.3.0.pdf, p. 1140](https://services.sergroup.com/documentation/#/view/PD_CSB_Short/14.3.0/en-us/UG_Doxis_CSB/WEBHELP/APP_CSB/topics/tsk_UserManual_Orgaadmin_Transport_ImportSelective.html))
   > The same page also says owner rights come across when rights are imported.

6. Decide how recipients should be matched in the target environment: by **name** or by **UUID**.

   > “by default, access right recipients for the transported objects (such as units, groups and roles) are identified by their name. When the check box is cleared, identification is based on the UUID.”
   > ([UG_Doxis_CSB_14.3.0.pdf, p. 1140](https://services.sergroup.com/documentation/#/view/PD_CSB_Short/14.3.0/en-us/UG_Doxis_CSB/WEBHELP/APP_CSB/topics/tsk_UserManual_Orgaadmin_Transport_ImportSelective.html))
   > The docs do not prescribe when to switch; they only define what the option does.

7. If you exported **access rules**, also enable **Import access rules**.

   > “By default, access rules are not imported.”
   > ([UG_Doxis_CSB_14.3.0.pdf, p. 1141](https://services.sergroup.com/documentation/#/view/PD_CSB_Short/14.3.0/en-us/UG_Doxis_CSB/WEBHELP/APP_CSB/topics/tsk_UserManual_Orgaadmin_Transport_ImportSelective.html))
   > Be careful: the same section warns that importing access rules for an already-existing rule type can replace the target’s existing rules of that type.

8. Decide whether target permissions should be **merged** or **replaced**.

   > “Overwrite permissions: If this option is selected, access rights in the target organization are fully replaced by access rights from the transport package. Otherwise, only missing entries are added.”
   > (UG_Doxis_CSB_14.3.0.pdf, p. 1144)

9. Run **Test run** before the real import.

   > “Click Test run if you want to simulate the import … This enables you to solve any problems before the actual import.”
   > (UG_Doxis_CSB_14.3.0.pdf, p. 1144)

10. Make sure the operator has the required admin rights.

> “ADM - Export transport package — The right to export transport packages…”
> “ADM - Import transport package — The right to import transport packages…”
> (UG_Doxis_cubeDesigner_14.4.0.pdf, p. 1693)

The shortest practical checklist is: include all relevant objects and dependencies, enable **Export user-specific permissions** when needed, enable **Export/Import access rules** when needed, keep **Import rights and ownerships** on, choose the correct **name vs. UUID** matching, and set **Overwrite permissions** deliberately.

If you want all transportable rights across the whole organization rather than a selective package, the docs point to **complete transport** instead:

> “the transportable data of an organization is completely exported”
> (UG_Doxis_CSB_14.3.0.pdf, p. 1119)
