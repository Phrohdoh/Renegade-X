class Rx_VoteMenuChoice_AddBots extends Rx_VoteMenuChoice;

var string ConsoleDisplayText;

var int BotsToTeam;
var int Amount;
var int Skill;

var int CurrentTier;

function array<string> GetDisplayStrings()
{
	local array<string> ret;

	if (CurrentTier == 0)
	{
		ret.AddItem("1: To GDI");
		ret.AddItem("2: To NOD");
		ret.AddItem("3: To both Teams");
	}
	else if (CurrentTier == 2)
	{
		ret.AddItem("1: Skill 1");
		ret.AddItem("2: Skill 2");
		ret.AddItem("3: Skill 3");
		ret.AddItem("4: Skill 4");
		ret.AddItem("5: Skill 5");
		ret.AddItem("6: Skill 6");
		ret.AddItem("7: Skill 7");
	}

	return ret;
}

function KeyPress(byte T)
{
	if (CurrentTier == 0)
	{
		// accept 1, 2, 3
		if (T == 1 || T == 2 || T == 3)
		{
			BotsToTeam = T;
			CurrentTier = 1;

			// enable console
			Handler.PlayerOwner.ShowVoteMenuConsole(ConsoleDisplayText);
		}
	}
	else if (CurrentTier == 2)
	{
		// accept 1 - 7
		if (T >= 1 && T <= 7)
		{
			Skill = T;

			Finish();
		}
	}
}

function InputFromConsole(string text)
{
	local string s;

	s = Right(text, Len(text) - 9);
	Amount = Min(int(s), 128); // do not go over 128 for now

	if (Amount <= 0)
	{
		Handler.Terminate();
		return;
	}

	CurrentTier = 2;
}

function bool GoBack()
{
	switch (CurrentTier)
	{
	case 0:
		return true; // kill this submenu
	case 1:
		CurrentTier = 0;
		return false;
	case 2:
		CurrentTier = 1;
		// enable console
		Handler.PlayerOwner.ShowVoteMenuConsole(ConsoleDisplayText);
		return false;
	}
}

function string SerializeParam()
{
	return string(BotsToTeam) $ "\n" $ string(Amount) $ "\n" $ string(Skill);
}

function DeserializeParam(string param)
{
	local int i;

	i = InStr(param, "\n");
	BotsToTeam = int(Left(param, i));
	param = Right(param, Len(param) - i - 1);
	i = InStr(param, "\n");
	Amount = int(Left(param, i));
	param = Right(param, Len(param) - i - 1);
	Skill = int(param);
}

function string ComposeTopString()
{
	local string str;

	str = super.ComposeTopString() $ " wants to add " $ string(Amount) $ " bots with skill " $ string(Skill) $ " to ";
	switch (BotsToTeam)
	{
	case 1:
		str = str $ "GDI";
		break;
	case 2:
		str = str $ "NOD";
		break;
	case 3:
		str = str $ "both teams";
		break;
	}

	return str;
}

function string ParametersLogString()
{
	local string teamPram;
	switch (BotsToTeam)
	{
	case 1:
		teamPram = "gdi";
		break;
	case 2:
		teamPram = "nod";
		break;
	case 3:
		teamPram = "both";
		break;
	}
	return "team:"$teamPram$",amount:"$Amount$",skill:"$Skill;
}

function Execute(Rx_Game game)
{
	local int i;

	// max is player max minus current bots and players 
	i = game.MaxPlayers - game.NumBots - game.NumPlayers;
	Amount = Min(Amount, i); 
	Amount = Max(Amount, 0);

	for (i = 0; i < Amount; i++)
	{
		// todo: apply skill
		if (BotsToTeam == 1 || BotsToTeam == 3)
			game.AddBot( , true, 0);
		if (BotsToTeam == 2 || BotsToTeam == 3)
			game.AddBot( , true, 1);
	}
}

DefaultProperties
{
	MenuDisplayString = "Add Bots"
	ConsoleDisplayText = "Amount of bots: "
}
