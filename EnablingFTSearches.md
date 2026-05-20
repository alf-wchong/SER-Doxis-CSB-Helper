# Enabling Full-Text searches on documents with cubeDesigner

## Steps to enable fulltext searching

1. **Open the existing document class**

   * Go to **Start > DMS > Document classes**.
   * Select the existing document class.

2. **Enable fulltext support for the document class**

   * In the document class **Object inspector**, use the **Fulltext** group.
   * Set **Allow indexing of content = True**.
     This only permits fulltext indexing; it does not by itself make every document fulltext-indexed. 

3. **Set automatic indexing for the default representation**

   * In **Fulltext mode default representation**, choose one of:

     * **Varying with MIME type**: recommended for normal use; indexes only suitable formats such as EML, HTML, Office, OpenOffice, PDF, RTF, text, and XML.
     * **Always**: indexes the default representation regardless of whether the format is suitable, using server-side Oracle OutsideIn filters.
   * Avoid **No fulltext** unless fulltext indexing will be triggered by script. 

4. **Check server-side MIME-type exclusions**

> [!NOTE]
> Doxis CSB administrators can globally exclude specific MIME types from fulltext indexing. If a format is not being indexed despite the document class setting, check the Doxis CSB configuration. 

6. **Decide whether additional fulltext areas are required**

   * Still in the document class **Fulltext** group, enable any needed optional indexing:

     * **Index annotations**
     * **Index descriptors**
     * **Index notes**
     * **Index ratings**
     * **Index custom items**
     * **Index line items**
> [!TIP]
> For a normal document-content fulltext search, the key setting is still **Fulltext mode default representation**. The optional settings extend what else is written to the fulltext index. 

7. **If descriptor values must be searchable via fulltext**

   * For each relevant descriptor, set **Allow fulltext indexing** on the descriptor. The guide states that such descriptor values are written both to the RDBMS and to a shared area of the fulltext index.
   * In the document class, set **Fulltext > Index descriptors** so the class can use the **Fulltext-enabled descriptors** object property.  

8. **Open the existing search class**

   * Go to **Start > Search & navigation > Search classes**.
   * Select the existing search class.
   * Verify that its **Databases** property includes the DMS database in which documents of the document class are filed. The guide states that the search class **Databases** property determines which Doxis CSB databases are considered in the search. 

9. **Open the existing search dialog**

   * Under the search class, select the existing search dialog.
> [!NOTE]
> Search dialogs define criteria for document, e-file, or process searches, and their controls can be bound to descriptors or object properties. 

10. **Add a fulltext search field to the search dialog**

   * In the **Object properties** tab, use the object property **Fulltext contents** / ID **Fulltext**.
   * Add it to the search dialog, preferably as a **multiline edit field** if users may enter longer search text.
> [!IMPORTANT] 
> **Fulltext contents / Fulltext** is the object property for document-content fulltext indexing and searching. 

11. **Configure the fulltext operator**

* In the fulltext control’s **Object inspector**, set the **Operator** if needed.
* For **Fulltext** controls, select either **STANDARD** and **SMART**. If no operator is set and the control is bound to the **Fulltext** object property, **STANDARD** is used automatically. 

11. **Optionally configure fulltext relevance**

* In the fulltext control, configure:

  * **Minimum relevance**
  * **Maximum distance**
* These properties are only relevant in search dialogs and control how fulltext result relevance is filtered. 

12. **Optionally enable keyword refinement**

* On the search dialog, set **Display key words = True** if users should see keyword suggestions after a fulltext search.
> [!IMPORTANT] 
> This requires a control bound to the **Fulltext** object property. This is done in step 10. 

13. **Check the result list**

* Make sure the search dialog has a **Result list** assigned, unless a dynamic result list is acceptable.
* For fulltext searches, consider setting the result list property **Optimize for fulltext search = True**. This removes existing grouping/sorting and sorts the result list by relevance during fulltext searches. 

14. **Configure hotspots if desired**

* In the result list, set **Display hotspots = True** to show relevant extracts from fulltext hits below result entries.
* Alternatively, add a result-list column bound to the **Hotspot** object property and set **Display hotspots = False** if hotspots should appear in a separate column. 

15. **Optionally add relevance to the result list**

* The object property **Relevance / Score** represents fulltext result quality from 0 to 1 and is assigned after a fulltext search. Add it as a result-list column if users need to see ranking. 

16. **Save the changed metadata**

* Save the document class, search dialog/search class, and result list changes.
* Runtime clients usually need a metadata refresh. The guide states that modified metadata objects become available in Doxis winCube only after logging off and back on; using **New logon** can refresh metadata. 

17. **Test with a document whose content is indexable**

* File a new document through the existing filing dialog.
* Use a file type covered by the selected fulltext mode, for example PDF, Office, EML, HTML, text, RTF, XML, or OpenOffice when using **Varying with MIME type**.
* Run the existing search dialog and enter text in the **Fulltext** field.
