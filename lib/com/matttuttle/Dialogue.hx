package com.matttuttle;

import com.matttuttle.DialogueContext;
import com.matttuttle.localization.Localization;

private typedef Saying = {
	text:String,
	params:List<String>
}

private enum Condition
{
	CondHas(type:OwnedType, ident:String, quantity:Int);
	CondStat(ident:String, compare:String, value:Int);
	CondBool(v:Bool);
}

private enum Expression
{
	OpIf(cond:Condition, block:Expression, eelse:Expression);
	OpBlock(l:List<Expression>);
	OpSay(say:Saying);
	OpResponse(say:Saying, actions:List<Action>);
	OpActions(action:List<Action>);
}

class Dialogue
{

	public function new(code:String)
	{
		var tokens = tokenize(code);
		expr = parseBlock(tokens);
	}

	public function run(context:DialogueContext)
	{
		this.context = context;
		context.reset();
		runExpr(expr);
	}

	private function runExpr(e:Expression)
	{
		switch (e)
		{
			case OpBlock(l):
				for (e in l)
					runExpr(e);
			case OpIf(cond, eif, eelse):
				var v:Bool = runCond(cond);
				if (v == null || v == false)
				{
					if (eelse != null)
					{
						runExpr(eelse);
					}
				}
				else
				{
					runExpr(eif);
				}
			case OpSay(saying):
				context.say(runSaying(saying));
			case OpResponse(saying, actions):
				context.respond(runSaying(saying), actions);
			case OpActions(actions):
				context.doActions(actions);
		}
	}

	private function runCond(cond:Condition):Bool
	{
		switch (cond)
		{
			case CondHas(type, name, quantity):
				return context.has(type, name, quantity);
			case CondStat(name, compare, value):
				var stat = context.actor.getStat(name);
				switch (compare)
				{
					case "=": return stat == value;
					case "<": return stat < value;
					case ">": return stat > value;
					case "<=": return stat <= value;
					case ">=": return stat >= value;
					case "!": return stat != value;
					default: throw "invalid comparison operator";
				}
			case CondBool(b):
				return b;
		}
		return false;
	}

	private function runSaying(saying:Saying):String
	{
		var params = new Array<String>();
		for (param in saying.params)
		{
			var val = Reflect.getProperty(context.actor, param);
			params.push(val);
		}
		return Localization.translate(saying.text, params);
	}

	private function parseBlock(tokens:List<String>):Expression
	{
		var l = new List();
		while (true)
		{
			var t = tokens.first();
			if (t == null || t == "end" || t == "else" || t == "elif")
				break;

			l.add(parse(tokens));
		}

		if (l.length == 1)
		{
			return l.first();
		}

		return OpBlock(l);
	}

	private function parse(tokens:List<String>):Expression
	{
		var t = tokens.pop();
		switch (t)
		{
			case "if":
				var cond = parseCond(tokens);
				t = tokens.pop(); // then
				var eif = parseBlock(tokens);
				var eelse = null;
				t = tokens.pop();
				if (t == null)
				{
					throw "unclosed if statement";
				}

				switch (t)
				{
					case "end":
					case "else":
						eelse = parseBlock(tokens);
						if (tokens.pop() != "end")
						{
							throw "unclosed else statement";
						}
					case "elif":
						tokens.push("if");
						eelse = parseBlock(tokens);
					default:
						tokens.push(t);
				}
				return OpIf(cond, eif, eelse);
			case "say":
				return OpSay(parseSaying(tokens));
			case "respond":
				var say = parseSaying(tokens);
				t = tokens.first();
				var actions = null;
				if (t == "do")
				{
					actions = parseActions(tokens);
				}
				return OpResponse(say, actions);
			case "do":
				return OpActions(parseActions(tokens));
		}
		throw "Expected expression, got " + t;
	}

	private function parseSaying(tokens:List<String>):Saying
	{
		var text = tokens.pop();
		var params = new List<String>();
		while (tokens.first() == ":")
		{
			tokens.pop();
			params.add(tokens.pop());
		}
		return { text: text, params: params };
	}

	private function parseCond(tokens:List<String>):Condition
	{
		while (true)
		{
			switch (tokens.first())
			{
				case "true":
					tokens.pop();
					return CondBool(true);
				case "false":
					tokens.pop();
					return CondBool(false);
				case "stat":
					tokens.pop();
					return CondStat(tokens.pop(), tokens.pop(), Std.parseInt(tokens.pop()));
				case "has":
					tokens.pop();
					return CondHas(parseOwnedType(tokens), tokens.pop(), parseQuantity(tokens));
				default: // then, null
					break;
			}
		}
		throw "Invalid token " + tokens.first();
	}

	private function parseOwnedType(tokens:List<String>):OwnedType
	{
		var t = tokens.pop();
		switch (t)
		{
			case "quest": return Quest;
			case "item": return Item;
			case "flag": return Flag;
			default: throw "Invalid type " + t;
		}
		return null;
	}

	private function parseRewardType(tokens:List<String>):RewardType
	{
		var t = tokens.pop();
		switch (t)
		{
			case "exp": return Experience;
			case "money": return Money;
			default: throw "Invalid reward type";
		}
		return null;
	}

	private function parseQuantity(tokens:List<String>):Int
	{
		var t = tokens.first();
		// TODO: get int at lexing stage...
		var int_re = ~/[0-9]+/;
		if (int_re.match(t))
		{
			t = tokens.pop();
			return Std.parseInt(t);
		}
		return 1;
	}

	private function parseActions(tokens:List<String>):List<Action>
	{
		var l = new List<Action>();
		while (true)
		{
			switch (tokens.first())
			{
				case "reward":
					tokens.pop();
					l.add(AReward(parseQuantity(tokens), parseRewardType(tokens)));
				case "remove":
					tokens.pop();
					l.add(ARemove(parseOwnedType(tokens), tokens.pop(), parseQuantity(tokens)));
				case "add":
					tokens.pop();
					l.add(AAdd(parseOwnedType(tokens), tokens.pop(), parseQuantity(tokens)));
				default: break;
			}
		}
		return l;
	}

	private function tokenize(code:String):List<String>
	{
		var i = 0, buf = "", size = code.length;
		var tokens = new List<String>();
		var inComment = false;

		while (i < size)
		{
			// get next char
			var c = code.charAt(i);
			i += 1;

			if (c == " " || c == "\t" || c == "\r" || c == "\n")
			{
				if (c != " ") inComment = false;

				if (buf != "")
				{
					tokens.add(buf);
					buf = "";
				}
				continue;
			}
			else if (c == "#")
			{
				inComment = true;
			}

			// don't add to buffer if we're in a comment
			if (!inComment)
			{
				buf += c;
			}
		}

		if (buf.length > 0)
		{
			tokens.add(buf);
		}

		return tokens;
	}

	private var expr:Expression;
	private var context:DialogueContext;

}