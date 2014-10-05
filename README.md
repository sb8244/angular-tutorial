About 4 months ago, I began my journey into Angular + Rails integrated. My company, SalesLoft, decided to try this out on a project and we are all really loving the outcome right now. There were some bumps along the way, and my goal today is to help you get past those things, explaining everything in detail, and leaving with a template that you can apply to other projects. Let's dive in! This is going to be a very newbie friendly tutorial, skip to the good parts if you are above that.

# Pre-reqs
* Ruby 2 / Rails (gem) on system
* Bower install (http://bower.io/)
* https://github.com/sb8244/angular-tutorial

# Create New Rails App
Let's create our Rails app (without testunit for now)

`rails new -T tutorial`

Once we do that, let's add in our bower components. We are going to replace the default Angular router with ui-router, Restangular for data access, and lodash is required with Angular.

#### bower.json
```
{
  "name": "Tutorial",
  "private": true,
  "ignore": [
    "**/.*",
    "node_modules",
    "bower_components",
    "test",
    "tests"
  ],
  "dependencies": {
    "lodash": "~2.4.1",
    "angular": "~1.2.22",
    "angular-ui-router": "~0.2.10",
    "restangular": "~1.4.0"
  }
}
```

The bowerrc file will tell bower where to install the components at, and we will put it in a more Rails-friendly place than the default

#### .bowerrc
```
{
  "directory": "vendor/assets/components"
}
```

Now you can run `bower install` and watch your components download. 

# Server Config

I have a goto Gemfile that I pull into most basic projects when I'm starting. I like to use SQLite for simple development things like this, and I use slim for templates because it is superior to everything else (agree or you're wrong). You can check out my `Gemfile` and use that for this project.

Let's add in our `config/initializers/slim.rb` file which will allow us to use Angular's `{{}}` symbols in our templates. By default, Slim tries to parse this as attributes which is obviously not what we want:

```
Slim::Engine.set_default_options attr_delims: { '(' => ')', '[' => ']' }
```

In `config/application.rb` we must add `config.assets.paths << Rails.root.join('vendor', 'assets', 'components')` inside the Application class. This will allow the asset pipeline to incorporate our Bower vendor components.

# Assets Config

The first thing to check out is the `assets/javascripts/application.js` file. This is the file that will load all of our scripts and bootstrap Angular. If we're going to use Rails + Angular together, then I think it is totally okay to use the asset pipeline, and so `//= require` is okay. I'm also creating the Angular APP and configuring the routes. Take note of  `RestangularProvider.setBaseUrl("/api");`. This is configuring the Restangular service to always hit /api endpoints. We will separate our Rails server this way.

The next big thing is the `javascripts/angular/templates.js.erb` file. This file will take advantage of the asset pipeline to grab all Slim templates in the `javascripts/angular/templates/*` directory and put them in the `$templateCache`. The `$templateCache` in Angular is always looked at when referencing a template, and this will ensure that our templates are loaded. If you follow my assets structure, you will not need to change this file, but it has some relative paths in it (be cautious if you move it).

# Routes Config

The last thing to get our application displaying on the frontend is to set up our `config/routes.rb` file. At the very bottom of the file, put:

```
get "*path", to: "application#index"
root 'application#index'
```

This will redirect any paths not defined previously to our catch-all `application#index` action.

Inside of your `controllers/application_controller.rb`, add the following action:

```
  def index
    render text: "", layout: "application"
  end
```

I'm choosing to not go over my very simple `layouts/application.html.slim` file, but I encourage you to go check it out. At this point in my application (commit "Step 2"), I have a screen that simply displays "hi" which is coming from a nested controller view. I know that Angular is working and I can add in a simple API route for us to consume.

# Rails API Setup

I like to isolate my Rails API under an API namespace, so I create a `controllers/api/base_controller.rb` file that all API controllers will inherit from. It disables authenticity token checks and says that it only responds to json by default.

I'm going to create a super basic model. This model will just be so we have something to demonstrate, run this and migrate your DB after:

`rails g model widget title:text content:text cool:boolean`

Now we will create an `Api::WidgetsController` class at `controllers/api/widgets_controller.rb`. If you do `rails g controller`, then please note that you will want to remove any assets, helpers, or views created by it. They will not be needed because we are just serving out JSON.

```
class Api::WidgetsController < Api::BaseController
  def index
    respond_with :api, widgets
  end

  def show
    respond_with :api, widget
  end

  def create
    respond_with :api, widgets.create(widget_params)
  end

  def destroy
    respond_with :api, widget.destroy
  end

  private

  def widgets
    @widgets ||= Widget.all
  end

  def widget
    @widget ||= widgets.find(params[:id])
  end

  def widget_params
    params.permit(:title, :content)
  end
end
```

And the following is added to `config/routes.rb` ABOVE the catch all routes. Remember that it must always be last.

```
  namespace :api do
    resources :widgets
  end
```

I really like the simplicity that the CRUD controller takes when using respond_with and json responses. It is so elegant that I can't get over it. Make sure you check out the specs to make sure it works!

# We are we at?

At this point, I have just committed my code as commit "Step 3". We have our Angular app loaded on the frontend and our Rails backend serving an api. So now we can use the api in Angular and display some data. To get that data, run `rake db:seed` to get 10 widgets created for you.

# Creating an Angular Controller

We're going to create our WidgetsListController at `assets/javascripts/angular/controllers/widgets.list.js`

```
APP.controller('WidgetsListController', ['$scope', 'Restangular', function($scope, Restangular) {
  Restangular.all("widgets").getList().then(function(widgets) {
    $scope.widgets = widgets;
  });
}]);
```

This isn't a very complex controller, but it really shows how elegant Restangular makes interaction with your Rails API. There's a whole slew of awesome features you get for free. There is a template that goes with this in `assets/javascripts/angular/templates/widgets/index.html.slim`. It's just a simple table.

I also went ahead and created a WidgetsShowController and view, but it isn't very exciting. The creation of a widget is much more interesting.

```
// This is in widgets.index.js
  $scope.create = function(widget) {
    Restangular.all("widgets").post(widget).then(function(widget) {
      $scope.widgets.push(widget);
    });
  };
```

I bind a create function that accepts a model, posts it to widgets, and appends the returned model onto the list which will immediately display in the table! I do that with this pretty simple form:

```
  form ng-show="showCreate === true" name="form"
    .form-controls.row
      .col-xs-3: label Title
      .col-xs-9: input.form-control name="title" ng-model="newWidget.title" required=true
    .form-controls.row
      .col-xs-3: label Content
      .col-xs-9: input.form-control name="content" ng-model="newWidget.content" required=true
    .form-controls.row
      .col-xs-3
      .col-xs-9: button.btn-block.btn.btn-success ng-click="create(newWidget)" ng-disabled="form.$invalid" Create
```

Angular's form directive will perform validations when it has a name and then I can disable the create button based on that. It's super slick!

For our last feature, remove will be added in. This will also go in the WidgetsListController:

```
  $scope.destroy = function(widget) {
    widget.remove().then(function() {
      _.remove($scope.widgets, function(w) {
        return w.id === widget.id;
      });
    });
  };
```

The reason I wanted to show this scope is that it accepts in a widget, and then calls remove() on it. `widget` is actually a Restangular object and has some convenience methods like `.remove()` on it. It couldn't be simpler!

# Wrapping Up

A lot goes into the setup of a new Angular app (about 30 minutes worth when the code already exists). The goal here was to get a project into your hands that integrates Rails + Angular without relying on the typial yeoman or node based Angular server. The full project, again, is at https://github.com/sb8244/angular-tutorial and the commit changes will give you a bit of insight into what I was thinking as I wrote this.

Thanks!
