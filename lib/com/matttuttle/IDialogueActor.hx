package com.matttuttle;

interface IDialogueActor
{
	public function earnMoney(amount:Int):Void;
	public function rewardExperience(amount:Int):Void;
	public function getStat(name:String):Int;

	public function addItem(name:String, ?quantity:Int):Void;
	public function removeItem(name:String, ?quantity:Int):Void;
	public function hasItem(name:String, ?quantity:Int):Bool;

	public function addQuest(name:String):Void;
	public function removeQuest(name:String):Void;
	public function hasQuest(name:String):Bool;
}