extends Node2D

var monkey = preload("res://Monkey.tscn")
var dog = preload("res://Dog.tscn")

var monkeys = []
var dogs = []

var nbElemsMax = 5
var time = 2

var score = 0
onready var global = get_node("/root/Global");

func _ready():
	get_tree().paused = false
	randomize()
	newTurn()
	$BestScore.set_text("Best Score : " + str(global.bestScore))
	
func _input(event):
	if event.is_action_pressed("dog"):
		vote(dogs.size())
	elif event.is_action_pressed("monkey"):
		vote(monkeys.size())
		
func vote(nb):
	var maxNb = max(monkeys.size(), dogs.size())
	if maxNb > nb:
		endGame()
	else:
		increaseScore()
		newTurn()

func increaseScore():
	score += 1
	$Score.set_text("SCORE : " + str(score))

func getNewPosition():
	return Vector2(randi() % 1200 + 40, randi() % 600 + 10)

func newTurn():
	$GuessTime.stop()
	emptyArrays()
	var nbMonkeys = randi() % (nbElemsMax - 1) + 1
	var nbDogs = randi() % (nbElemsMax - 1) + 1
	if nbDogs == nbMonkeys:
		nbDogs += 1
	
	for i in range(nbMonkeys):
		var node = monkey.instance()
		node.position = getNewPosition()
		node.rotate(randf() * 2 * PI)
		add_child(node)
		monkeys.push_back(node)
		
	for i in range(nbDogs):
		var node = dog.instance()
		node.position = getNewPosition()
		node.rotate(randf() * 2 * PI)
		add_child(node)
		dogs.push_back(node)
		
	nbElemsMax += 1
	$GuessTime.wait_time = time
	$GuessTime.start()
	
func emptyArrays():
	for item in monkeys:
		item.queue_free()
		
	for item in dogs:
		item.queue_free()
	
	monkeys = []
	dogs = []

func endGame():
	global.bestScore = max(score, global.bestScore)
	emptyArrays()
	$RemainingTime.visible = false
	$GameOver.visible = true
	get_tree().paused = true
	$RestartGame.start()

func _on_RestartGame_timeout():
	get_tree().reload_current_scene()

func _on_GuessTime_timeout():
	endGame()

func _process(delta):
	var timeLeft = round($GuessTime.time_left * 100) / 100
	$RemainingTime.set_text(str(timeLeft))