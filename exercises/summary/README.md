## What You Have Seen

In exercises 2 and 3, you have seen the **basic steps to integrate a remote service** like

- **Projections** on a remote API defintion
- **Delegate queries** to the remote service
- **Mash up** the remote service with local services
- **Optimize** performance by adding on-demand replication
- **Mock** the remote service for local development

Check out the cookbook about [Consuming Services](https://cap.cloud.sap/docs/guides/using-services) for more.

Check out the [Reuse and Compose](https://cap.cloud.sap/docs/guides/extensibility/composition) guide for more on **integration packages**.

## How to Continue

You might want to **save your work** so that you can continue later on.  Do this by

- Committing your changes: `git add -A && git commit -m 'Workshop changes'`
- [Forking](https://docs.github.com/en/get-started/quickstart/fork-a-repo#forking-a-repository) this repository to your personal GitHub account. Then change the remote URL of your local repo accordingly: `git remote set-url origin <ForkURL>`
- Pushing the commits with `git push`

Check out the **complete version** of the application in the `final` branch of the repository: `git checkout final` <br>
This branch:

- Shows you the final stage of the application, plus
- **Augments** the imported BusinessPartner model, e.g. adds missing ON conditions
- Integrates business partner **addresses** on top

  ![Customer with address](assets/address.png)

Deploy the application to SAP BTP.  See the [deploy guides](https://cap.cloud.sap/docs/guides/deployment/) for more.

> Note that you need an SAP BTP trial account here.
