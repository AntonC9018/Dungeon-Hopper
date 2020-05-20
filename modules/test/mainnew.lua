return {
	requiredMods = {},
    bases = {
        entity = {
            Enemy      = require '.base.enemy',
            EnvObject  = require '.base.envobject',
            Player     = require '.base.player',
            Tile       = require '.base.tile',
            Projectile = require '.base.projectile',
            Trap       = require '.base.trap',
            Wall       = require '.base.wall'
        },
        item = {
            -- TODO: include shield and shell here
        }
    },
    entities = {
       Bomb = require '.entities.bomb',
       BounceTrap = require '.entities.bouncetrap',
       Candace = require '.entities.candace',
       Chest = require '.entities.chest',
       Coals = require '.entities.coals',
       Crate = require '.entities.crate',
       Dirt = require '.entities.dirt',
       TestEnemy = require '.entities.enemytest',
       IceCube = require '.entities.icecube',
       Joe = require '.entities.joe',
       Projectile = require '.entities.projectile',
       Spider = require '.entities.spider',
	   Water = require '.entities.water',
	   
	   -- include this as an entity too
	   Tile = require '.base.tile',
	},
	items = {
		shell = require '.items.shell',
		shield = require '.items.shield',
		spear = require '.items.spear',
		testitem = require '.items.testitem'
	},
	decorators = {}, -- you can choose not to expose e.g. decorators
	attackSources = {
		'Bounce',
		'Proj',
		'Coals',
		'Explosion'
	},
	stats = {
		StuckRes = { 
			'resistance', 
			{ 'stuck', 1 }, 
			HowToReturn.NUMBER 
		}
		Explosion = {
			'explosion', 
			require '.effects.explosion',
        	HowToReturn.EFFECT
		}        
	},
	status = {
		freeze = require '.status.freeze',
		bind = require '.status.bind',
		stun = require '.status.stun'
	}
}