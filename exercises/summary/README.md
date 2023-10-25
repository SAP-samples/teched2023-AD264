## What You Have Seen

In exercise 1, you have seen many of the basic feature of SAP Cloud Application Programming Model (CAP):

- **Projects** can be created with just one click and incrementally grown as you go
- **CDS entities** are a concise way to express the basic structure of your data model
- **Projections** in CDS services are a powerful means tailor your entities for specific APIs
- **CDS services** allow to expose entities as API
- **Reuse libraries** are available for commonly used entities and fields
- **OData** as a protocol is served out of the box and has powerful querying capabilities

In exercises 2 and 3, you have seen the **basic steps to integrate a remote service** like

- **Projections** on a remote API defintion
- **Delegate queries** to the remote service
- **Mash up** the remote service with local services
- **Optimize** performance by adding on-demand replication
- **Mock** the remote service for local development
- **Integration packages** that can be used to provide reusable projections, event definitions, service implementations, and sample data.

Check out the cookbook about [Consuming Services](https://cap.cloud.sap/docs/guides/using-services) for more.


## How to Continue

You might want to **save your work** so that you can continue later on.  Do this by

- Committing your changes: `git add -A && git commit -m 'Workshop changes'`
- [Forking](https://docs.github.com/en/get-started/quickstart/fork-a-repo#forking-a-repository) this repository to your personal GitHub account. Then change the remote URL of your local repo accordingly: `git remote set-url origin <ForkURL>`
- Pushing the commits with `git push`


Check out the **complete version** of the application in the `final` branch of the repository: `git checkout final` <br>

### Further Learning

Go through [session AD161](https://github.com/SAP-samples/teched2023-AD161) which covers basically the same scenario, but
- Focuses on **visual tools** provided in SAP Business Application Studio
- Adds an **full UI application with SAP Fiori Elements**
- Includes application **deployment to SAP BTP**.  Note that you need an SAP BTP trial account here.
- Shows an integration with **SAP Build Workzone**