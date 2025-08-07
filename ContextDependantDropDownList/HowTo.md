![EFiling dialog](images/1.EFilingdialog.png)

The dropdown control, `Counterparty` is actually two separate downdown lists. Both dropdown lists mapped to the same descriptor. When the dialog is first drawn, both dropdown lists are invisible. Either appears depending on whether LNG is selected for `Desk`.
This behavior is achieved by creating dependencies on the dialog through cubeDesigner. 
![EFiling dialog](images/2.DependenciesInDialog.png)

Create the dependency

![EFiling dialog](images/3.CreateDependencies.png)

Create the rule

![EFiling dialog](images/4.CreateRule.png)

Remember to create a converse dependency for the other dropdown list so that when one appears, the other dissapears. Save and relogin webCube to test.

I used REGEX for the rule. From what I gather, start the rule with `~=` and then enter the REGEX to evaluate as true for the condition specified in the dependency. So, in the example above, the REGEX `^(|LNG)$` is true when `nothing is selected` for the `Desk` control or when `LNG` is selected for `Desk`. 
See [cubeDesigner's user guide](https://services.sergroup.com/documentation/api/documentations/23/340/1037/WEBHELP/APP_cubeDesigner/topics/tsk_Dialogs_ConfigureDependencies.html) for full description.
