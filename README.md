# Godot Eloquence

![GitHub Tag](https://img.shields.io/github/v/tag/markhj/godot-eloquence?label=version)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?label=license)

> This addon is still in very early development stage, and is subject to
> rapid changes. Furthermore, some documentation is still lacking.

**_Godot Eloquence_** is an Object-Relational Mapping (ORM) for
Godot, specifically built for
[Godot-SQLite](https://godotengine.org/asset-library/asset/1686).

The name is a nod to Laravel's
[Eloquent](https://laravel.com/docs/11.x/eloquent), which serves
as inspiration for this addon.

## 💫 Prerequisites

- Godot 4.3 or higher
- Godot-SQLite

> Git LFS (Large File Storage) is used for binaries
> (e.g. ``.dll``, ``.a``, etc.) of _Godot-SQLite_.

> _Godot-SQLite_ and 
> [_GodotUnit_](https://github.com/markhj/godot-unit) 
> are part of this project scope,
> but are only relevant for testing of the addon. They will (should)
> not be transferred as part of installation of the addon.

## 🌿 Features

- Query builder
- Active record
- Life-cycle hooks (on_load, on_save, etc.)
- Relations

## 🚀 Installation

> Add-on is not yet distributed as an official repository.

The most straight-forward way to install an add-on which is not yet published
on the official Godot repository, is good old copy/paste.

Download the source code and extract it.
Then copy ``addons/godot-eloquence`` to the identical location in your project.
Do _not_ copy the other files, such as the ``tools`` folder.

Last step is to activate the plugin under **Project Settings &rarr; Addons**.

## 📗 Documentation

The documentation is available at [github.io](https://markhj.github.io/godot-eloquence/).

## ▶️ Getting started

### Connecting

The first step we'll just review very quickly, because it relates more
to setting up SQLite than it has much to do with _Godot Eloquence_.

A very basic way of connecting the _SQLite_ database would look like this:

````GDScript
var db: SQLite = SQLite.new()
db.path = "res://path/to/your_db.sqlite"
assert(db.open_db(), "Failed to open database.")
````

### Set data source

However, now comes an important step: Adding the database connection
to ``DataSource`` which is used by _Eloquence_ to access the SQLite instance.

````GDScript
DataSource.add(db)
````

## 💾 Note about database schemas

_Eloquence_ expects a column named ``id`` which is used as a unique identifier
for each row.

## ✒️ Writing a basic model

A **model** (or **active record**) is a reference to a specific row in a 
database table. It makes reading from and writing to a record much easier,
and more intuitive, mainly in that you won't need to work directly with queries.

````GDScript
extends SQLiteModel

class_name User

func setup() -> void:
	table = TableDefinition.create("users")
````

The class ``User`` is now tied to the ``users`` table, and you can already
query from the table, as well as write updates back to it.

### Find

The simplest command is the ``find`` which loads a record from the table.

````GDScript
var user = User.new().find(123)
````

### Attributes

You can read and write attributes like this:

````GDScript
var email = user.get_attr("email")

user.set_attr("name", "John Doe")
````

### Saving

However, you may notice that after using ``set_attr`` the object still
isn't saved to the database. For this, you need to call ``save``:

````GDScript
user.save()
````

If you're working with an "empty" object (one not loaded off the database),
this method will insert the record in the database
(and tie itself specifically to that record). That is:

````GDScript
var user = User.new()
user.set_attr("new.user@example.com")
user.save()   # Will create a new record and return the ID
````

## 🚧 Work in progress

This library is still in a very early stage, therefore a lot of documentation
is still missing. There's already a lot more to explore than the few features
examined above.

Feel free to explore the library, in particular the tests,
where you can find lots of use-cases.

Full documentation will come soon!
