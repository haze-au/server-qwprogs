class mitem_playerpreview : mitem_spinnymodel
{
#if 1//defined(FTE_QC_CUSTOMSKINS)
	virtual void(vector pos) item_draw =
	{
		//if you wanted to get more advanced, you could use q3 skins here.
		if (cvar("noskins"))
			setcustomskin(self, "", sprintf("q1upper \"%s\"\nq1lower \"%s\"\n\n", cvar_string("topcolor"), cvar_string("bottomcolor")));
		else if (cvar_string("cl_teamskin") != "")
			setcustomskin(self, "", sprintf("q1upper \"%s\"\nq1lower \"%s\"\nqwskin \"%s\"\n", cvar_string("topcolor"), cvar_string("bottomcolor"), cvar_string("cl_teamskin")));
		else
			setcustomskin(self, "", sprintf("q1upper \"%s\"\nq1lower \"%s\"\nqwskin \"%s\"\n", cvar_string("topcolor"), cvar_string("bottomcolor"), cvar_string("skin")));
	
		super::item_draw(pos);
	};
#endif
};

static string() skinopts =
{
	string opts = "";
	float s = search_begin("skins/*.pcx", TRUE, TRUE);
	if (s < 0)
		return opts;
	float n = search_getsize(s);
	for (float i = 0; i < n; i++)
	{
		string f = substring(search_getfilename(s, i), 6, -5);
		opts = strcat(opts, "\"", f, "\" \"", f, "\" ");
	}
	return opts;
};

var float autocvar_m_pitch = 0.022;
class options_basic : mitem_exmenu
{
	virtual float(string key) isvalid =
	{
		if (key == "m_pitchsign")
			return TRUE;
		if (key == "cl_run")
			return TRUE;
		return super::isvalid(key);
	};
	virtual string(string key) get =
	{
		if (key == "m_pitchsign")
			return (autocvar_m_pitch<0)?"1":"0";
		if (key == "cl_run")
			return (stof(super::get("cl_forwardspeed")) > 200)?"1":"0";
		//if (key == "fo_grentimer")
		//	return getplayerkeyvalue(player_localnum, "nt");
		return super::get(key);
	};
	virtual void(string key, string newval) set =
	{
		if (key == "m_pitchsign")
		{
			float invert;
			if (stof(newval))
				invert = autocvar_m_pitch > 0;
			else
				invert = autocvar_m_pitch < 0;
			if (invert)
				cvar_set("m_pitch", ftos(-autocvar_m_pitch));
		}
		else if (key == "cl_run")
		{
			float setbackspeed = (super::get("cl_backspeed") != "");
			if (stof(newval))
			{
				super::set("cl_forwardspeed", "400");
				super::set("cl_sidespeed", "400");
				if (setbackspeed)
					super::set("cl_backspeed", "400");
				super::set("cl_movespeedkey", "0.5");	//makes +speed act like +walk
			}
			else
			{
				//these are the defaults from winquake.
				super::set("cl_forwardspeed", "200");
				super::set("cl_sidespeed", "350");
				if (setbackspeed)
					super::set("cl_backspeed", "200");
				super::set("cl_movespeedkey", "2.0");
			}
		}
		else
			super::set(key, newval);
	};
};
nonstatic void(mitem_desktop desktop) M_Options_Basic =
{
	mitem_exmenu m;
	m = spawn(options_basic, item_text:_("Basic Options"), item_flags:IF_SELECTABLE, item_command:"m_options");
	desktop.add(m, RS_X_MIN_PARENT_MIN|RS_Y_MIN_PARENT_MIN | RS_X_MAX_PARENT_MAX|RS_Y_MAX_PARENT_MAX, '0 0', '0 0');
	desktop.item_focuschange(m, IF_KFOCUSED);
	m.totop();

	float h = 200 * 0.5;
	//draw title art above the options
	mitem_pic banner = spawn(mitem_pic, item_text:"gfx/ttl_cstm.lmp", item_size_y:24, item_flags:IF_CENTERALIGN);
	m.add(banner, RS_X_MIN_PARENT_MID|RS_Y_MIN_PARENT_MID | RS_X_MAX_OWN_MIN|RS_Y_MAX_PARENT_MID, [(160-160-banner.item_size_x)*0.5, -h-32], [banner.item_size_x, -h-8]);
	//spawn a container frame for the actual options. this provides a scrollbar if we have too many items.
	mitem_frame fr = spawn(mitem_frame, item_flags: IF_SELECTABLE, frame_hasscroll:TRUE);
	m.add(fr, RS_X_MIN_PARENT_MID|RS_Y_MIN_PARENT_MID | RS_X_MAX_PARENT_MID|RS_Y_MAX_OWN_MIN, [-160, -h], [160, h*2]);
	float fl = RS_X_MIN_PARENT_MIN|RS_Y_MIN_PARENT_MIN | RS_X_MAX_PARENT_MAX|RS_Y_MAX_OWN_MIN;
	float pos = 0;
	

	fr.add(menuitemeditt_spawn(_("Player Name"), 		dp("_cl_name", "name"), 			'280 8'), 	fl, [0, pos], [0, 8]); pos += 8;
	//fr.add(menuitemeditt_spawn(_("Player Team"), 		"team",						'280 8'), 	fl, [0, pos], [0, 8]); pos += 8;
	//fr.add(menuitemcombo_spawn(_("Player Skin"), 		"skin",						'280 8', 	skinopts()), fl, [0, pos], [0, 8]); pos += 8;
																	
																	
	//fr.add(menuitemcolour_spawn(_("Upper Colour"), 	"topcolor", 					'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	//fr.add(menuitemcolour_spawn(_("Lower Colour"), 	"bottomcolor", 					'280 8'),	fl, [0, pos], [0, 8]); pos += 8;	/*aka: arse colour*/
	pos += 8;
	fr.add(menuitemcheck_spawn (_("Always Run"),		"cl_run", 					'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	fr.add(menuitemcheck_spawn (_("Invert Mouse"),		"m_pitchsign", 					'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	fr.add(menuitemslider_spawn(_("Sensitivity"),		"sensitivity", 			'3 20 1',	'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	fr.add(menuitemslider_spawn(_("Fov"),			"fov", 				'80 130 5',	'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	fr.add(menuitemslider_spawn(_("Viewmodel Fov"),		"r_viewmodel_fov", 		'80 130 5',	'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	fr.add(menuitemslider_spawn(_("Gamma"),			dp("v_gamma", "gamma"), 	'0.8 1.2 0.05',	'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	fr.add(menuitemslider_spawn(_("Contrast"),		dp("v_contrast", "contrast"), 	'0.8 1.2 0.05', 	'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	fr.add(menuitemslider_spawn(_("Brightness"),		dp("v_brightness", "brightness"),'-0.2 0.2 0.05', '280 8'),	fl, [0, pos], [0, 8]); pos += 8;
    pos += 8;
    fr.add(
            spawn(
                mitem_text,
                item_text:strcat("^{e080} ^a","Crosshair","^d ^{e082}"),
                item_command:"",
                item_scale:8,
                item_flags:IF_CENTERALIGN
                ),
            RS_X_MIN_PARENT_MID|RS_Y_MIN_PARENT_MIN | RS_X_MAX_PARENT_MID|RS_Y_MAX_OWN_MIN,
            [0, pos],
            [0, 8]
          ); pos += 8;
    pos += 8;
	fr.add(menuitemslider_spawn(_("Type"),		        "crosshair", 			'0.0 19 1', 	'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	fr.add(menuitemcolour_spawn(_("Color"), 		    "crosshaircolor", 		'280 8'), 	fl, [0, pos], [0, 8]); pos += 8;
	fr.add(menuitemcheck_spawn (_("Use Team Color"),    "fo_team_color_crosshair", '280 8'),	fl, [0, pos], [0, 8]); pos += 8;
    pos += 8;
    fr.add(
            spawn(
                mitem_text,
                item_text:strcat("^{e080} ^a","Grenades","^d ^{e082}"),
                item_command:"",
                item_scale:8,
                item_flags:IF_CENTERALIGN
                ),
            RS_X_MIN_PARENT_MID|RS_Y_MIN_PARENT_MIN | RS_X_MAX_PARENT_MID|RS_Y_MAX_OWN_MIN,
            [0, pos],
            [0, 8]
          ); pos += 8;
    pos += 8;
    fr.add(menuitemcombo_spawn (_("Timer"),		"fo_grentimer", 		'280 8', _(
                    "2	\"On\" "
                    "0	\"Silent\" "
                    )),	fl, [0, pos], [0, 8]); pos += 8;
    fr.add(menuitemcombo_spawn (_("Sound"),		"fo_grentimersound", 		'280 8', _(
                    "grentimer.wav          \"Default\" "
                    "mcp_grentimer1.wav	    \"1\" "
                    "mcp_grentimer2.wav	    \"2\" "
                    "mcp_grentimer3.wav	    \"3\" "
                    "mcp_grentimer4.wav	    \"4\" "
                    "mcp_grentimer5.wav	    \"5\" "
                    "mcp_grentimer6.wav	    \"6\" "
                    "mcp_grentimer7.wav	    \"7\" "
                    "mcp_grentimer8.wav	    \"8\" "
                    "mcp_grentimer9.wav 	\"9\" "
                    "mcp_grentimer10.wav	\"10\" "
                    "mcp_grentimer11.wav	\"11\" "
                    "mcp_grentimer12.wav	\"12\" "
                    "mcp_grentimer13.wav	\"13\" "
                    "mcp_grentimer14.wav	\"14\" "
                    "mcp_grentimer15.wav	\"15\" "
                    "mcp_grentimer16.wav	\"16\" "
                    "mcp_grentimer17.wav	\"17\" "
                    "mcp_grentimer18.wav	\"18\" "
                    "mcp_grentimer19.wav	\"19\" "
                    "mcp_grentimer20.wav	\"20\" "
                    "mcp_grentimer21.wav	\"21\" "
                    "mcp_grentimer22.wav	\"22\" "
                    "mcp_grentimer23.wav	\"23\" "
                    "mcp_grentimer24.wav	\"24\" "
                    "mcp_grentimer25.wav	\"25\" "
                    "mcp_grentimer26.wav	\"26\" "
                    )),	fl, [0, pos], [0, 8]); pos += 8;


	/* fr.add(menuitemcheck_spawn (_("Simple Bunnyhop"),		"fo_autohop", 					'280 8'),	fl, [0, pos], [0, 8]); pos += 8; */
	//fr.add(menuitemcheck_spawn (_("Grenade Timer"),		"fo_grentimer", 					'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	/* fr.add(menuitemcombo_spawn (_("Grenade Timer"),		"fo_grentimer", 					'280 8', _( */
	/* 																	"0	\"None\" " */
	/* 																	"1	\"Server\" " */
	/* 																	"2	\"Immediate\" " */
	/* 														)),	fl, [0, pos], [0, 8]); pos += 8; */
	//fr.add(menuitemslider_spawn(_("TF Status Bar"),		"crosshair", 			'0.0 19 1', 	'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	//fr.add(menuitemslider_spawn(_("TF Flag Info"),		"crosshair", 			'0.0 19 1', 	'280 8'),	fl, [0, pos], [0, 8]); pos += 8;
	
	local string skin = "tf_sold";
	local float r = random();
	if(r > 0.89)
		skin = "tf_scout";
	else if(r > 0.78)
		skin = "tf_snipe";
	else if(r > 0.67)
		skin = "tf_demo";
	else if(r > 0.56)
		skin = "tf_medic";
	else if(r > 0.45)
		skin = "tf_hwguy";
	else if(r > 0.34)
		skin = "tf_pyro";
	else if(r > 0.23)
		skin = "tf_spy";
	else if(r > 0.12)
		skin = "tf_eng";

	
	//m.add(spawn (mitem_spinnymodel, item_text: it), RS_X_MIN_PARENT_MID|RS_Y_MIN_PARENT_MID | RS_X_MAX_PARENT_MID|RS_Y_MAX_PARENT_MID, [-160, 12*-16/2], [0, 12*16/2]);
	m.add(spawn (mitem_spinnymodel, item_text: "progs/player.mdl", firstframe:12, framecount:5, shootframe:119, shootframes:6, dontrotate:1, startangle:'0 155 0', customskin:skin, rotatespeed:10, topcolour:0, bottomcolour:0), RS_X_MIN_PARENT_MID|RS_Y_MIN_PARENT_MID | RS_X_MAX_PARENT_MID|RS_Y_MAX_PARENT_MID, [-300, 16*-16/2], [-40, 16*16/2]);
//	m.add(spawn (mitem_playerpreview, item_text: "progs/player.mdl", firstframe:0, framecount:6, shootframe:119, shootframes:6), RS_X_MIN_PARENT_MID|RS_Y_MIN_PARENT_MID | RS_X_MAX_PARENT_MID|RS_Y_MAX_PARENT_MID, [-200, 12*-16/2], [-40, 12*16/2]);

	addmenuback(m);
};
