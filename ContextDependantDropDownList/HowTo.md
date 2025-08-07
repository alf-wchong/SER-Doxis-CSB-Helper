![EFiling dialog](images/1.EFilingdialog.png)

The dropdown control, `Counterparty` is actually two separate downdown lists. When the dialog is first drawn, both dropdown lists are invisible. Either appears depending on whether LNG is selected for `Desk`.
This behavior is achieved by creating dependencies on the dialog through cubeDesigner. 
![EFiling dialog](images/2.DependenciesInDialog.png)

Create the dependency

![EFiling dialog](images/3.CreateDependencies.png)

Create the rule

![EFiling dialog](images/4.CreateRule.png)

Remember to create a converse dependency for the other dropdown list so that when one appears, the other dissapears. Save and relogin webCube to test.
