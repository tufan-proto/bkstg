# [Backstage](https://backstage.io)

This is your newly scaffolded Backstage App, Good Luck!

To start the app, run:

```sh
yarn install
yarn dev
```

## Starting from scratch

If you ever need to recreate this project from scratch, these following steps will help

### Create the backstage app 
We'll call the app `bkstg` and use the `sqlite` data base here. For production, a good idea to use `postgres`. We'll also initialize a git repo for good measure.

```null
npx @backstage/create-app

cd bkstg
git init
echo node_modules >> .gitignore
echo dist >> .gitignore
git add .
git commit -m "feat: initial commit"
```

Creates a directory structure that looks like this.

```null
bkstg
└── packages
    ├── app       # the front-end/web-ui
    └── backend   # the api server - this connects to a database.
```


### Customize & Adapt the application

At this point, we have a default backstage-app and have initialized a git-repo
to manage the application.

We need to make a few modifications to allow it to be easily managed within a CI/CD
pipeline. There changes a little scattered all over, but it's not really too bad. 
[This change-list](https://github.com/acuity-sr/bkstg-one/compare/14622c6..9176b21) enumerates the required changes.

While we won't get into each change, we will highlight the following:
1. `.github/workflows/ci.yaml`: the CI workflow for the module. This would need to be customized for your app
2. `.github/workflows/cd.yaml`: the CD workflow for the module. This might beed to be customized for your app.
3. `Dockerfile`: the instructions to build a container of your app. In the case of backstage, there is only one container for the backend+app, but this would be extended to two (or more) containers. Customize for your app as necessary.

### Github secrets
GH_ACTIONS: A [personal-access-token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) with `repo` permissions

ACUITY_SECRET: A `dev-ops` secret that provides access to previously encrypted
Service Principal credentials. This is a weak mechanism for storing/sharing
credentials across a team. A key-vault based mechanism should replace this.
