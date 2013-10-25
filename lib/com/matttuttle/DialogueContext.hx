package com.matttuttle;

enum OwnedType
{
	Quest;
	Item;
	Flag;
}

enum RewardType
{
	Experience;
	Money;
}

enum Action
{
	AReward(amount:Int, type:RewardType);
	ARemove(type:OwnedType, name:String, quantity:Int);
	AAdd(type:OwnedType, name:String, quantity:Int);
}

class DialogueContext
{

	public var saying:String;
	public var responses:Array<String>;
	public var actor(default, null):IDialogueActor;

	public function new(actor:IDialogueActor)
	{
		this.actor = actor;
		flags = new Map<String,Int>();
		reset();
	}

	public function reset()
	{
		saying = "";
		responses = new Array<String>();
		actions = new Array<List<Action>>();
	}

	public function say(text:String)
	{
		saying = text;
	}

	public function respond(text:String, a:List<Action>)
	{
		responses.push(text);
		actions.push(a);
	}

	public function choose(index:Int)
	{
		if (actions.length - 1 < index || index < 0) throw "Invalid response index";
		doActions(actions[index]);
	}

	public function doActions(actions:List<Action>)
	{
		if (actions == null) return;
		for (action in actions)
		{
			switch (action)
			{
				case AReward(amount, type):
					switch (type)
					{
						case Money: actor.earnMoney(amount);
						case Experience: actor.rewardExperience(amount);
					}
				case ARemove(type, name, quantity):
					switch (type)
					{
						case Item: actor.removeItem(name, quantity);
						case Quest: actor.removeQuest(name);
						case Flag: flags.remove(name);
					}
				case AAdd(type, name, quantity):
					switch (type)
					{
						case Item: actor.addItem(name, quantity);
						case Quest: actor.addQuest(name);
						case Flag: flags.set(name, quantity);
					}
			}
		}
	}

	public function has(type:OwnedType, name:String, quantity:Int):Bool
	{
		switch (type)
		{
			case Item: return actor.hasItem(name, quantity);
			case Quest: return actor.hasQuest(name);
			case Flag: return flags.exists(name);
		}
	}

	private var flags:Map<String,Int>;
	private var actions:Array<List<Action>>;
}