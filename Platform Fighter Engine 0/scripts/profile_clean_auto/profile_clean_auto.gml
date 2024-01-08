///@category Profiles
/*
Deletes all profiles marked as autogenerated.
*/
function profile_clean_auto()
	{
	log("Number of Profiles Before Clean: ", array_length(engine().profiles));
	for (var i = 0; i < array_length(engine().profiles); i++)
		{
		if (profile_get(i, PROFILE.autogenerated))
			{
			profile_destroy(i);
			i--; 
			}
		}
	log("Number of Profiles After Clean: ", array_length(engine().profiles));
	}
/* Copyright 2023 Springroll Games / Yosi */