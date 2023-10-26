# Exercise 1 - Introduction to CAP

In this exercise, you will build a small application with SAP Cloud Application Programming Model (CAP).

You will use this application scenario throughout the exercises.
Also, you will get familiar with CAP and the CDS language.

The conceptual domain model for this _Incidents Management_ application is as follows:

- *Customers* can create *Incidents* (either directly or via agents)
- *Incidents* have a title, a status and and urgency level
- *Incidents* contain a *Conversation* history consisting of several messages

<p>

![Domain model](assets/domain.drawio.svg)


## Create a Project

👉 In SAP Business Application Studio, create a new _CAP Project_.
- Name it `incidents-mgt`, for example.
- Accept the rest of the defaults.  No sample code needed; you will fill the project as you go.

<details>
<summary>These screenshots help you find the project wizard:</summary>

![New CAP Project](assets/BAS-NewProject.png)

![New CAP Project - Details](assets/BAS-NewProject-Details.png)

</details>
<p>

> You might also create the project with `cds init incidents-mgt` on the command line in the `/home/user/projects` folder.


## Add Incidents

👉 Create a file `data-model.cds` in the `db` folder.
- There, add an `Incidents` [entity](https://cap.cloud.sap/docs/cds/cdl#entities) with a key field `ID` and a `title`.
- Choose appropriate data types.  Use code completion (intellisense) to pick a fitting data type.
- Also, add a namespace `incidents.mgt` to the beginning of the file, so that the entity's full name is `incidents.mgt.Incidents`

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

## Use Predefined Aspects

The situation of `ID` key fields is so common that there is a prebuilt CDS aspect available named `cuid` that provides just that.<br>
It can be imported with `using ... from '@sap/cds/common';` and used in an entity with the `:` (colon) syntax.

Also, the `Incidents` entity shall carry information on when it was created and updated and by whom.  There is a [`managed` aspect from `@sap/cds/common`](https://cap.cloud.sap/docs/cds/common#aspect-managed) that does that.

👉 Make use of the two aspects and:
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

👉 Take a few moments and check out what the `@sap/cds/common` package has to offer in addition.  In the editor, hold <kbd>Ctrl</kbd> (or <kbd>⌘</kbd>) and hover over the `managed` text.  Click to navigate inside.
See the [documentation](https://cap.cloud.sap/docs/cds/common) for more.


## Add a Conversation History

An incident shall hold a number of messages to build a conversation history.

To create such a relationship, the **graphical CDS modeler** in SAP Business Application Studio is a great tool.<br>
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
using { cuid, managed } from '@sap/cds/common';

namespace incidents.mgt;

entity Incidents : cuid, managed {
  title         : String(100);
  conversations : Composition of many Conversations on conversations.incidents = $self;
}

entity Conversations : cuid, managed {
  timestamp : DateTime;
  author    : String(100);
  message   : String;
  incidents : Association to Incidents;
}
```

</details>

> To open the code editor, just double-click on the `db/data-model.cds` file in the explorer tree.

> In the following exercises, feel free to use the graphical modeler or the code editor as you like. Find out what works for you.<br>
In the solutions though, we will print the textual form, as it's more convenient to copy/paste.


## Add Status and Urgency

Incidents shall have two more fields `status` and `urgency`, which are 'code lists', i.e. configuration data.

👉 Add two entities, using the [`CodeList`](https://cap.cloud.sap/docs/cds/common#aspect-codelist) aspect.
- `Status` for the incident's status like _new_, _in process_ etc.
- `Urgency` to denote the priority like _high_, _medium_ etc.

👉 Add two fields to `Incidents` pointing to the new entities.  This time, use the [`extend` directive](https://cap.cloud.sap/docs/cds/cdl#extend) to add the fields w/o having to modify the original definition.

<details>
<summary>See the result:</summary>

In `db/data-model.cds`, add:

```cds
using { sap.common.CodeList } from '@sap/cds/common';

entity Status : CodeList {
  key code  : String;
}

entity Urgency : CodeList {
  key code : String;
}

extend Incidents with {
  urgency       : Association to Urgency;
  status        : Association to Status;
};
```

</details>

## Create a CDS Service

There shall be an API for incidents processors to maintain incidents.

👉 In a new file `srv/processor-service.cds`, create a [CDS service](https://cap.cloud.sap/docs/cds/cdl#service-definitions) that exposes a one-to-one projection on `Incidents`.<br>

<details>
<summary>This is how the service should like:</summary>

```cds
using { incidents.mgt } from '../db/data-model';

service ProcessorService {

  entity Incidents as projection on mgt.Incidents;

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

- An in-memory [SQLite database](https://cap.cloud.sap/docs/guides/databases-sqlite) got created.  This holds the application data (which we don't have yet).
  ```sh
  [cds] - connect to db > sqlite { database: ':memory:' }
  /> successfully deployed to in-memory database.
  ```

- The CDS service got exposed on this path:
  ```sh
  [cds] - serving ProcessorService { path: '/odata/v4/processor' }
  ```


👉 Now <kbd>Ctrl+Click</kbd> on the `http://localhost:4004` link in the terminal.
- In SAP Business Application Studio, this URL gets automatically transformed to an address like `https://port4004-workspaces-ws-...applicationstudio.cloud.sap/`
- If you work locally, this would be http://localhost:4004.

## Add Sample Data

Add some test data to work with.

👉 Create **csv files** for all entities in the terminal:

```sh
cds add data
```

> Note how the files names match the entity names.<br>
  As soon as they are there, `cds watch` finds and deploys them. Check the console output:
  ```sh
  [cds] - connect to db > sqlite { database: ':memory:' }
  > init from db/data/incidents.mgt-Urgency.texts.csv
  > init from db/data/incidents.mgt-Urgency.csv
  > init from db/data/incidents.mgt-Status.texts.csv
  > init from db/data/incidents.mgt-Status.csv
  > init from db/data/incidents.mgt-Incidents.csv
  > init from db/data/incidents.mgt-Conversations.csv
  ```

👉 For the two code lists, **fill in data in the terminal** real quick:

```sh
cat << EOF > db/data/incidents.mgt-Status.csv
code,name
N,New
I,In Process
C,Closed
EOF

cat << EOF > db/data/incidents.mgt-Urgency.csv
code,name
H,High
M,Medium
L,Low
EOF
```

👉 For the `Incidents` and `Conversations` csv files, use the **sample data editor** to fill in some data.
- Double click on the `db/data/incidents.mgt-Incidents.csv` file in the explorer tree.
- In the editor, add maybe 10 rows.  Use the `Number of rows` field and click `Add` to create the records.
- Also create records for the `db/data/incidents.mgt-Conversations` file. The editor automatically fills the `incidents_ID` foreign key.

👉 On the applications index page, click on the `Incidents` link which runs a `GET /odata/v4/processor/Incidents` request.<br>


## Add a Simple UI

👉 Click on _Incidents_ > _[Fiori Preview](https://cap.cloud.sap/docs/advanced/fiori#sap-fiori-preview)_ on the index page of the application.  This opens an SAP Fiori Elements application that was created on the fly.  It displays the entity's data in a list.

The list seems to be empty although there is data available .  This is because no columns are configured.  Let's change that.

👉 Add a file `app/annotations.cds` with this content:

```cds
using { ProcessorService as service } from '../srv/processor-service';

annotate service.Incidents with @UI : {
  LineItem  : [
    { $Type : 'UI.DataField', Value : title},
    { $Type : 'UI.DataField', Value : modifiedAt },
    { $Type : 'UI.DataField', Value : modifiedBy },
  ],
};
```

which creates 3 columns:

![Fiori list page with 3 columns](assets/Fiori-simple.png)

There is even preconfigured labels for the `modifiedAt` and `modifiedBy` columns.<br>
👉 Do you know how to look them up?  Hint: use editor features.

<details>
<summary>See how:</summary>

On the `managed` aspect in `db/data-model.cds`, select _Go to References_ from the context menu.  Expand `common.cds` in the right-hand tree and check the `annotate managed` entries until you see the `@title` annotations:

![Dialog with all references of the managed aspect](assets/Editor-GoToReferences.png)

The actual strings seem to be fetched from a resource bundle that is addressed with a `{i18n>...}` key.  See the [localization guide](https://cap.cloud.sap/docs/guides/i18n) for how this works.

</details>

<p>

The label for the `title` column seems to be wrong, though.<br>
👉 Fix it by adding the appropriate [CDS annotation](https://cap.cloud.sap/docs/advanced/fiori#prefer-title-and-description) to the `Incidents.title` element.

<details>
<summary>This is how you can do it:</summary>

Add a `@title:'Title'` annotation to the `Incidents` definition.  Make sure to place it correctly before the semicolon.  Watch out for syntax errors.

```cds
entity Incidents : cuid, managed {
  title         : String(100) @title : 'Title';   // <--
  ...
}
```

Note that annotations can be added at [different places in the CDS syntax](https://cap.cloud.sap/docs/cds/cdl#annotations).

</details>

## Add Another Service

In the service above, you have used only the very minimal form of a [CDS projection](https://cap.cloud.sap/docs/cds/cdl#views-and-projections), which basically does a one-to-one exposure of an entity to the API surface:

```cds
service ProcessorService {
  entity Incidents as projection on mgt.Incidents;
}
```

However, projections go way beyond this and provide powerful means to express queries for specific application scenarios.
- When mapped to relational databases, such projections are in fact translated to SQL views.
- You will soon see non-DB uses of projections.

👉 Now explore projections and services.  Add a 'statistics service' that shows
- Incidents' `title`
- Their `status`, but showing `New` instead of `N` etc.  Hint: use a [path expression](https://cap.cloud.sap/docs/cds/cql#path-expressions) for the `name`.
- Only urgent incidents.  Hint: use a [`where` condition](https://cap.cloud.sap/docs/cds/cql).

The result shall be available at `/odata/v4/statistics/UrgentIncidents`. What's the name of the CDS service that matches to this URL?

Also, use the editor's code completion that guides you along the syntax.<br>

<details>
<summary>Solution:</summary>

In a separate `srv/statistics-service.cds` file, add this:

```cds
using { incidents.mgt } from '../db/data-model';

service StatisticsService {

  entity UrgentIncidents as projection on mgt.Incidents {
    title,                  // expose as is
    status.name as status,  // expose with alias name using a path expression
  }
  where urgency.code = 'H'  // filter
}
```
</details>

<p>

👉 If you got this, add these fields with more advanced syntax:
- `modified` :  a concatenated string from `modifiedAt` and `modifiedBy` (use the `str1 || str2` syntax)
- `convCount` :  a count for the number of conversation messages.  Hint: SQL has a `count()` function.  Don't forget the `group by` clause.

<details>
<summary>Solution:</summary>

```cds
using { incidents.mgt } from '../db/data-model';

service StatisticsService {

  entity UrgentIncidents as projection on mgt.Incidents {
    title,                  // expose as is
    status.name as status,  // expose with alias name using a path expression

    modifiedAt || ' (' || modifiedBy || ')' as modified : String,
    count(conversations.ID) as convCount : Integer
  }
  where urgency.code = 'H' // filter
  group by ID              // needed for count()
}
```
</details>

<p>

Remember: you got all of this power without a single line of (Javascript or Java) code!


## Test OData Features

👉 In the browser, use the service URL `.../odata/v4/processor/Incidents` and
- list incidents
- with their conversation messages,
- limiting the list to `5` entries,
- only showing the `title` field,
- sorting alphabetically along `title`

How can you do that using [OData's](https://cap.cloud.sap/docs/advanced/odata) query options like `$expand` etc.?
<details>
<summary>This is how:</summary>

Add
```
?$select=title&$orderby=title&$top=5&$expand=conversations
```

to the URL.

</details>

## Inspect the Database

Upon deployment to the database, CAP creates SQL DDL statements to create the tables and views for your entities.

👉 On the `db/data-model.cds` file, select `CDS Preview > Preview as sql` from the editor's context menu.  This opens a side panel with the SQL statements.

<details>
<summary>See how this looks like:</summary>

![SQL preview for data model](assets/PreviewAsSQL.png)

</details>

You can do the same in the terminal with
```sh
cds compile db --to sql
```

👉 Now do the same on file `srv/statistics-service.cds`.  What is different in the result?  Can you explain where the new SQL statements come from?

<details>
<summary>This is why:</summary>

For each CDS projection, an SQL view is created that captures the queries from the projections.

</details>

## Summary

You've now created a basic version of the Incidents Management Application.  Still it's very powerful as it:
- Exposes **rich API's** and OData metadata.  You will see OData clients like SAP Fiori Elements UI soon.
- Deploys to a **database out-of-the-box**.
- Let's you stay **focused on the domain model** without the need to write imperative code for simple CRUD requests.
- Keeps boilerplate **files to the minimum**.  Just count the actual files in the project.

Now continue to [exercise 2](../ex2/README.md), where you will extend the application with remote capabilities.
