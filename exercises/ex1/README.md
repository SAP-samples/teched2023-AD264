# Exercise 1 - Create the Application

In this exercise, you will build a small application with SAP Cloud Application Programming Model (CAP).
You will use it throughout the exercises

Also, you will get familiar with CAP and the CDS language.

## Create a Project

👉 In SAP Business Application Studio, create a new _CAP Project_.  Name it `incidents-mgt`, for example.

<details>
<summary>These screenshots help you find the project wizard:</summary>

![New CAP Project](assets/BAS-NewProject.png)

![New CAP Project - Details](assets/BAS-NewProject-Details.png)

</details>


## Add Incidents

👉 Create a file `data-model.cds` in the `db` folder.
- There, add an `Incidents` entity with a key field `ID` and a `title`.
- Choose appropriate data types.  Use code completion (intellisense) to pick a fitting data type.
- Also, add a namespace `incidents.mgt` to the beginning of the file, so that the entity's full name is `incidents.mgt.Incidents`

> See the [documentation](https://cap.cloud.sap/docs/cds/cdl) for the syntax of entity definitions.

<details>
<summary>This is how it should like:</summary>

```cds
namespace incidents.mgt;

entity Incidents {
  key ID       : UUID;
  title        : String;
}
```
</details>

## Use Common Predefined Aspects

The situation of `ID` key fields is so common that there is a prebuilt CDS aspect available named `cuid` that provides just that.<br>
It can be imported with `using ... from '@sap/cds/common';` and used in an entity with the `:` (colon) syntax.

Also, the `Incidents` entity shall carry information on when it was created and updated and by whom.  There is a `managed` aspect from `@sap/cds/common` that does that.

👉 Make use of the two aspects:
- Replace the hand-crafted `ID` field with `cuid`<br>
- Add the `managed` aspect.


<details>
<summary>This is how it should like:</summary>

```cds
using { cuid, managed } from '@sap/cds/common';

entity Incidents : cuid, managed {
  title        : String;
}
```
</details>

<p>

👉 Take a few moments and check out what the `@sap/cds/common` package has to offer in addition.  In the editor, hold <kbd>Ctrl</kbd> (or <kbd>⌘</kbd>) and hover over the `managed` text.  Click to naviate inside.
See the [documentation](https://cap.cloud.sap/docs/cds/common) for more.


## Add a Conversation History

An incident shall hold a number of messages to build a conversation history.

To create such a relationship, the **graphical CDS modeler** is a great tool.<br>
👉 Open it for the `data-model.cds` file using one of two options:
- Right click the `data-model.cds` file.  Select `Open With` > `CDS Graphical Modeler`
- Or open the modeler through the project **Storyboard**:
  - Press <kbd>F1</kbd> > `Open Storyboard`
  - Click on the `Incidents` entity > `Open in Graphical Modeler`

👉 In its canvas, add a `Conversations` entity.
- In the `Aspects` tab in the property sheet, add the `ID` key field from CDS aspect `cuid`.
- Add `timestamp`, `author`, and `message` fields with appropriate types.

👉 Now connect the two entities.  In the `New Relationship` dialog:
- Choose a releationship type so that whenever an `Incident` instance is deleted, all its conversations are deleted as well.
- Stay with the proposed `conversations` and `incidents` fields.


<details>
<summary>All in all, the entities shall look like this:</summary>

![Incidents and Conversations entities in graphical modeler](assets/Incidents-Conversations-graphical.png)

As text, it looks like this:

```cds
entity Incidents : cuid, managed {
  title : String(100);
  conversations : Composition of many Conversations on conversations.incidents = $self;
}

entity Conversations : cuid, managed {
  timestamp : DateTime;
  author : String(100);
  message : String;
  incidents : Association to Incidents;
}
```

> To open the code editor, just double-click on the `db/data-model.cds` file in the explorer tree.

</details>


## Create a CDS Service

There shall be an API for incidents processors to maintain incidents.

👉 In a new file `srv/processor-service.cds`, create a [CDS service](https://cap.cloud.sap/docs/cds/cdl#service-definitions) that exposes a one-to-one projection on `Incidents`.<br>
👉 Also [annotate](https://cap.cloud.sap/docs/cds/cdl#annotations) the projection entity with `@odata.draft.enabled` so that incidents can be modified with an SAP Fiori Elements UI.

<details>
<summary>This is how the service should like:</summary>

```cds
using { incidents.mgt as db } from '../db/data-model';

service ProcessorService {

  @odata.draft.enabled
  entity Incidents as projection on db.Incidents;

}
```

</details>

## Start the Application

👉 Run the application:
- Open a terminal.  Press <kbd>F1</kbd>, type _new terminal_, or use the main menu.
- In the terminal, execute in the project root folder:

  ```sh
  cds watch
  ```

  <details>
  <summary>See the console output:</summary>

  ![Start application, terminal output](assets/StartApp-Terminal.png)
  </details>
  <p>

Take a moment and check the output for what is going on:

- The application consists of three `cds` files.  Two are application sources and one comes from the `@sap/cds` library:
  ```sh
  [cds] - loaded model from 3 file(s):

    srv/processor-service.cds
    db/data-model.cds
    .../@sap/cds/common.cds
  ```

- An in-memory SQLite database got created.  This holds the application data (which we don't have yet)
  ```sh
  [cds] - connect to db > sqlite { database: ':memory:' }
  /> successfully deployed to in-memory database.
  ```

- The CDS service got exposed on this path:
  ```sh
  [cds] - serving ProcessorService { path: '/odata/v4/processor' }
  ```


👉 Now <kbd>Ctrl</kbd>-click on the `http://localhost:4004` link in the terminal.  The application is opened with an address like `https://port4004-workspaces-ws-...applicationstudio.cloud.sap/` (if you work locally, this would be http://localhost:4004).


## Add Sample Data

Add some test data to work with.

👉 Create **csv files** in the terminal:

```sh
mkdir -p db/data
touch db/data/incidents.mgt-Incidents.csv
touch db/data/incidents.mgt-Conversations.csv
```

> Note how the files names match the entity names.<br>
  As soon as they are there, `cds watch` finds and deploys them. Check the console output:
  ```sh
  [cds] - connect to db > sqlite { database: ':memory:' }
  > init from db/data/incidents.mgt-Incidents.csv
  > init from db/data/incidents.mgt-Conversations.csv
  ```

👉 Use the **sample data editor** to fill in some data.
- Right click on one of the csv files and run `Open With...` > `Sample Data Editor`
- In the editor, add maybe 10 rows.  Use the `Number of rows` field and click `Add` to create the records.
- Also create records for the second csv file.

👉 On the applications index page, click on the `Incidents` link which runs a `GET /odata/v4/processor/Incidents` request.<br>


### Test out-of-the-box Features

👉 Use the URL from above and list incidents
- with their conversation messages,
- limiting the list to `5` entries,
- only showing the incidents' `title`,
- sorting along `title`

How can you do that using [OData's](https://cap.cloud.sap/docs/advanced/odata) query options like `$expand` etc.?
<details>
<summary>This is how:</summary>

Add
```
?$select=title&$orderby=title&$top=5&$expand=conversations
```

to the URL.

</details>



<!-- On the application's index page, go to **Incidents → Fiori preview**, which opens an SAP Fiori elements list page for the `Incidents` entity.  It should look like this:

![Incidents UI](assets/InitialUI.png)

> With regards to the UI screens that you see here: this is not a tutorial on SAP Fiori.  Instead, we use the minimal screens necessary to illustrate the relevant points.  For a full-fledged SAP Fiori Elements application using CAP, see the [SFlight application](https://github.com/SAP-samples/cap-sflight/). -->



<!-- ## Take a Look Behind the Scenes -->


## Summary

You've now created a basic version of the Incidents Management Application.

Continue to - [Exercise 2 - Exercise 2 Description](../ex2/README.md)

