#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#using scripts\zm\_zm_perks;

#insert scripts\zm\perks\_zm_perk_berserker.gsh;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "client_fx", BERSERKER_FX );

#namespace zm_perk_berserker;

REGISTER_SYSTEM_EX( "zm_perk_berserker", &init, &main, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function init()
{
	if ( IS_TRUE( BERSERKER_LEVEL_USE_PERK ) )
		enable_berserker_perk_for_level();
}

function main()
{
	if ( IS_TRUE( BERSERKER_LEVEL_USE_PERK ) )
		perk_logic();
}

function enable_berserker_perk_for_level()
{
	zm_perks::register_perk_clientfields( 				BERSERKER_PERK, &berserker_client_field_func, &berserker_callback_func );
	zm_perks::register_perk_effects( 					BERSERKER_PERK, BERSERKER_PERK );
	zm_perks::register_perk_init_thread( 				BERSERKER_PERK, &berserker_init );
}

function berserker_init()
{
	level._effect[ BERSERKER_PERK ] = BERSERKER_FX;
}

function berserker_client_field_func() 
{
	clientfield::register( "clientuimodel", BERSERKER_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function berserker_callback_func()
{

}

//*****************************************************************************
// FUNCTIONALITY
//*****************************************************************************

function perk_logic()
{

}