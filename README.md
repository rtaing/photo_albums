# PhotoAlbums

Share your photos online with password protection, so only the people you want to view the photos can see them.

## Features

* Create multiple, sortable albums
* Batch upload photos
* Sort photo order by drag and dropping photos
* View responsive photos with a mobile-first design
* Download the original full size photos
* Assign cover photos to albums
* Have a single password so people do not need to create accounts
* Run functional and system tests!

This app is also useful if you'd like to see the following gems and libraries in action:

* [paperclip](https://github.com/thoughtbot/paperclip) for multiple file uploads.
* [Magnific Popup](http://dimsemenov.com/plugins/magnific-popup/) for the gallery view of photos.
* [Sortable](https://github.com/RubaXa/Sortable) for drag and drop reordering.
* [Rails system tests](http://guides.rubyonrails.org/testing.html#system-testing) with minitest and Capybara

## Requirements

Rails >= 5.1 is required due to the system tests.

## Setup

For development, run `bundle install` and then change the paperclip_defaults in application.rb.  Uncomment either the filesystem or s3 section and set enviroment variables if required.

Migrate the database with `rake db:migrate`

To initialize passwords and get photos and albums into the app, seed with `rake db:seed`.  The general, non-admin password will be `password` and the admin password will be `admin`.

If you do not want to seed the database or you would like to set up the users yourself, you can use the create_custom method:

    User.create_custom('admin', true)
    User.create_custom('password')

Log in as an admin to CRUD and sort the albums and photos

## Testing

If gems have already been installed from the setup step, you can start by migrating the database in the test environment: `rake db:migrate RAILS_ENV=test`

You'll need to install PhantomJS because poltergeist is the system test driver.  You can view instructions in the [poltergeist](https://github.com/teampoltergeist/poltergeist) gem.

Then run tests with `rails test` and `rails test:system`

## Deploy

PhotoAlbums can be deployed to Heroku.  The actual process (creating git repo, creating Heroku app, pushing to Heroku, etc) can be found in Heroku's guides.

You need to use s3 or another external file store.  You can uncomment the s3 section in application.rb or override it in production.rb.

Make sure you set the environment variables, migrate the database, and then manually create the passwords via Heroku's console:

    heroku run console
    User.create_custom('better_admin_password', true)
    User.create_custom('better_password')

Note that Heroku has a timeout of 30 seconds, which means that batch uploads are limited to about 4 photos at a time.  If you do try to upload more, the photos are eventually processed, but there will be some duplicates due to the action reprocessing the request.  This can be solved by updating the code to not process photos with duplicate file names (which would mean all new photos can't have the same name), or uploading to s3 directly and creating a background process to poll and process those directly uploaded photos.
