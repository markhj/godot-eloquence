extends Control

var db: SQLite = SQLite.new()

var default_db: String = "res://tests/assets/default.sqlite"

var db_path: String = "res://storage/temp_db.sqlite"

@onready var test_summary: Control = $TestSummary

func _ready():
	db.path = db_path
	
	if FileAccess.file_exists(db_path):
		assert(DirAccess.remove_absolute(db_path) == 0, "Failed to remove temp. database")
		
	assert(DirAccess.copy_absolute(default_db, db_path) == 0, "Failed to copy default database.")
	assert(db.open_db(), "Failed to open database.")
	
	DataSource.add(db)
	
	var results = TestRunner.new().run([
		BasicModelTest.new(),
		ModelIOTest.new(),
		QueryBuilderTest.new(),
		QueryExecuteTest.new(),
		RelationsTest.new(),
	])
	
	test_summary.results = results
