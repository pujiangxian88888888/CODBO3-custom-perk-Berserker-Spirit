#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\gameobjects_shared;
#using scripts\shared\demo_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;

#insert scripts\zm\perks\_zm_perk_berserker.gsh;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_laststand.gsh;

//#precache( "string", "BERSERKER_PERK_BERSERKER_STRING" );
#precache( "fx", BERSERKER_FX );

#namespace zm_perk_berserker;

REGISTER_SYSTEM( "zm_perk_berserker", &init, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function init()
{	
	zm_perks::register_perk_basic_info( BERSERKER_PERK, "berserkerperk", BERSERKER_PERK_COST, "Hold ^3[{+activate}]^7 for Berserker Spirit [Cost: &&1]", GetWeapon( BERSERKER_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( BERSERKER_PERK, &berserker_precache );
	zm_perks::register_perk_clientfields( BERSERKER_PERK, &berserker_register_clientfield, &berserker_set_clientfield );
	zm_perks::register_perk_machine( BERSERKER_PERK, &berserker_perk_machine_setup );
	zm_perks::register_perk_threads( BERSERKER_PERK, &berserker_perk_give, &berserker_perk_take );
	zm_perks::register_perk_host_migration_params( BERSERKER_PERK, BERSERKER_RADIANT_MACHINE_NAME, BERSERKER_PERK);
	
	ARRAY_ADD( level._random_perk_machine_perk_list, BERSERKER_PERK);
}

function berserker_precache()
{
	level._effect[ BERSERKER_PERK ] 							= BERSERKER_FX;

	level.machine_assets[ BERSERKER_PERK ] 					= spawnStruct();
	level.machine_assets[ BERSERKER_PERK ].weapon 			= getWeapon( BERSERKER_PERK_BOTTLE_WEAPON );
	level.machine_assets[ BERSERKER_PERK ].off_model 		= BERSERKER_MACHINE_DISABLED_MODEL;
	level.machine_assets[ BERSERKER_PERK ].on_model 			= BERSERKER_MACHINE_ACTIVE_MODEL;	
}

function berserker_register_clientfield() 
{
	clientfield::register( "clientuimodel", BERSERKER_CLIENTFIELD, VERSION_SHIP, 2, "int" );
}

function berserker_set_clientfield( state ) 
{
	self clientfield::set_player_uimodel( BERSERKER_CLIENTFIELD, state );
}

function berserker_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound 				= BERSERKER_JINGLE;
	use_trigger.script_string 				= BERSERKER_SCRIPT_STRING;
	use_trigger.script_label 				= BERSERKER_STING;
	use_trigger.target 						= BERSERKER_RADIANT_MACHINE_NAME;
	perk_machine.script_string 				= BERSERKER_SCRIPT_STRING;
	perk_machine.targetname 				= BERSERKER_RADIANT_MACHINE_NAME;
}

function berserker_perk_give()
{
	//IPrintLnBold("giving perk");
	self notify(BERSERKER_PERK + "_start");
	self thread perk_logic();
}

function berserker_perk_take( b_pause, str_perk, str_result )
{
	self notify( "perk_lost", str_perk );
	self notify( BERSERKER_PERK + "_stop" );	
}

function berserker_perk_host_migration_func()
{
	a_perk_machines = getEntArray( BERSERKER_RADIANT_MACHINE_NAME, "targetname" );
	
	foreach ( perk_machine in a_perk_machines )
	{
		if ( isDefined( perk_machine.model ) && perk_machine.model == BERSERKER_MACHINE_ACTIVE_MODEL )
		{
			perk_machine zm_perks::perk_fx( undefined, 1 );
			perk_machine thread zm_perks::perk_fx( BERSERKER_ALIAS );
		}
	}
}

//*****************************************************************************
// FUNCTIONALITY
//*****************************************************************************

function perk_logic()
{
	zm::register_actor_damage_callback( &actor_damage_override );
}

function actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex, surfacetype)
{
	if( meansofdeath === "MOD_MELEE"
	||  meansofdeath === "MOD_PISTOL_BULLET"
	||  meansofdeath === "MOD_RIFLE_BULLET"
	||  meansofdeath === "MOD_HEAD_SHOT")
	{
		if( isdefined( attacker ) && isdefined( attacker.health ) && attacker HasPerk( BERSERKER_PERK ))
		{	
			if( attacker HasPerk( PERK_JUGGERNOG ) )
			{ 
				if     ( attacker.health <=155 && attacker.health > 110 )
				damage *= 2;
				else if( attacker.health <=110 && attacker.health > 65 )
				damage *= 3;
				else if( attacker.health <=65 && attacker.health > 20 )
				damage *= 4;
				else if( attacker.health <=20 )
				damage *= 10;
			}
			else
			{
				if     ( attacker.health <=55 && attacker.health > 10 )
				damage *= 2;
				else if( attacker.health <=10 )
				damage *= 5;
			}
		}
		return damage;
	}
	return -1;
}