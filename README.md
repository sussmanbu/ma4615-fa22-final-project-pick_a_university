# MA[46]15 Final Project

**Make sure to read the full README file below, all pages and posts on your initial site, and look through the files in the `content` folder and the `config.toml` file.**

For your final project, your team will be 


* finding data,
* cleaning the data,
* performing an exploratory data analysis, 
* using statistical models and other techniques to draw conclusions, and
* communicating what you learned on website.

We'll use the `blogdown` package to maintain our website. `blogdown` makes things easier but there are still some snags that you might run into. 
You will be working with your group to maintain the website, providing weekly blog posts and culminating with the deployment of pages detailing your analysis.


Here are the steps you'll need to take. __Please only start this once you have a set team of 4 or 5__.


0. Your team will share a Github repository for the final project. Accept this assignment and make sure to pick your team. The first person who accepts will have to create a new team. Also, make sure to accept the invitation to the sussmanbu organization on Github.
1. Choose a team member to be in charge of the _Netlify_ account which is used to host the web site. Let me know the Github user name for this team member.

## Steps for Netlify Setup (only one team member should do this)

2. Go to [https://www.netlify.com/](https://www.netlify.com/). Click _Sign Up_ and use your Github account. Follow the steps to sign up.
3. Once you are set up and logged in, click _New site from Git_. Click _Github_ and authorize Netlify to access your account by clicking "Configure the Netlify app on GitHub" link. (If you have trouble with this step it might be because I need to add you to the `sussmanbu` organization.)
4. Find your teams repository using the _Search repos_ field and select it from the list.
5. You shouldn't have to adjust any options so click _Deploy Site_. Your site is now being deployed.
6. In the meantime, click _Site Settings_ and then _Change site name_ and use your team name (or something close) as the site name.
7. You should now be able to go back to _Overview_, see that "Your site is deployed", and click on the link to see your site. 


## Steps for Everyone

Set up options as per ?new_post

2. Clone your repository to your laptop and open the project file.
3. Install the blogdown package using `install.packages("blogdown")`. 
4. Run `blogdown::install_hugo()`. _Hugo_ / _blogdown_ are the tools for transforming your site from Markdown/RMarkdown into the structure of the website.
5. Run the command `blogdown::serve_site()`. If all goes well you will see a preview of the site in the RStudio Viewer.

__WARNING__ Always use `blogdown::serve_site()` to preview your changes and updates.

## Steps for the Group

Everyone should now have their computer set up with blogdown, hugo and your team should have their netlify account up.
In turn do the following.

0. Press Pull in the Git tab to get the latest changes.
1. Open the `about.md` file from the `content` folder and add your name to the file, write a quick introduction, and include a link to your Github account page. (The first person can remove Wan-chi and Dan from the list).
2. Commit the changes to `about.md` and Push your changes.
3. Check that your changes are showing up on netlify.
4. Make sure to wait until one team member is done before the next person starts again at 0.

Finally, the last person to update the about page will update the `config.toml` file.
The only change you need to make is to update the `title` to be your group name.
Again, commit and push your changes.

You should be all set and see the changes again on netlify.

Read through the posts on your website to learn a bit about how things work. Look at the structure of the `content` folder and compare it to the website structure.


## How does blogdown work?

Blogdown works with Hugo to build website out of markdown and R markdown files.
The details are not too important but there are a few key things.

First, most of the time you will be working in the `content` folder. This is where the RMarkdown files will live.

Blogdown takes the files in `content` and knits them into `html` files. Hugo uses the files in the `themes` folder to figure what the pages should look like and to construct the site with all the links and layouts.
I picked out a `theme` that I like and made a few changes. You are welcome to keep it, change it, or use a different theme but be aware that this can become tricky.

Hugo also includes anything in the `static` folder as-is on your site, so this is where Blogdown puts all the files for the figures. It is also a good place to keep your data or add in your own images.

Finally, once you run `serve_site`, you should see a new folder called `public`. This folder is where the built website lives. Generally, you can just ignore this folder since any edits you make should be in the `content` folder or `static`.
Note that our `.gitignore` file tells `git` to ignore any changes in the `public` folder.
This is because Netlify will run Hugo for you and deploy the resulting public folder onto their servers.

__NOTE__ Netlify only runs Hugo so it will not compile your R markdown files. This is why you have to commit the `html` files, as otherwise those pages/posts will not appear.

## What to commit?

With `blogdown` it can get a little tricky to know what should be committed and what should not.
For example, if you click Preview in RStudio when you are editing the About page, R will compile that to an `html` file.
If you commit this the website might not look the way we want it to.

To preview files, always use the `blogdown::serve_site()` command and navigate to the page you are working on.
Every time you save, blogdown will rebuild the website and tell you if you had any errors.
(Don't use the `knit` button in RStudio. If you do you'll have to make sure that `blogdown` re-knits that page.)
To stop previewing the website you can run `blogdown::stop_server()`

Make sure to frequently check that you don't have any problems with `blogdown::check_site()`. This may give you a hint about something to correct.

Some general guidelines are:

1. Always commit `.Rmd` and `.Rmarkdown` files. Otherwise, your teammates won't be able to see the original R code.
2. Always commit `.md` files.
3. Usually commit `.html` files unless they share a name with a `.md` file.
4. Always commit changes in the `static` folder.

__Never__ commit large data files. This can cause some challenges. 
