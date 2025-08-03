-- This is updated for 0711a using code from Wildcard Collection. 

--the mod icon
SMODS.Atlas{
    key = 'modicon',
    path = 'modicon.png',
    px = 34,
    py = 34
}

-- Jimmy-B3: test joker lol
-- Arya: I got no clue why we're keeping this, but I'm sure you got a reason. 
SMODS.Atlas{
    key = 'TestJoker',
    path = 'testjoker.png',
    px = 71,
    py = 95
}

SMODS.Joker{
    key = "test",
    loc_txt = {
        name = 'Horse.',
        text = {
            "A random horse. Maybe it does something..."
        }
    },
        rarity = 4,
        cost = -1,
        blueprint_compat = false,
        eternal_compat = false,
        perishable_compat = false,
        discovered = true,
    atlas = 'TestJoker',
    pos = {x = 0, y = 0},
    config = { 
        extra = {
            Xmult = 2
        }
    },
}

--Red
SMODS.Atlas{
    key = 'colors',
    path = 'colorsprites.png',
    px = 71,
    py = 95
}

SMODS.Enhancement{
 key = 'red',
 loc_txt = {
    name = 'Red',
    text = {
        '{X:mult,C:white}X#1#{} {C:mult}Mult{}'
    }
 },
 atlas = 'colors',
 pos = { x = 0, y = 0 },
 config = {
  x_mult = 1.5
 },
 loc_vars = function(self, info_queue, card)
  return { vars = { card.ability.x_mult } }
 end
}

--Orange
SMODS.Enhancement{
 key = 'orange',
 loc_txt = {
    name = 'Orange',
    text = {
        '{C:attention}Upgrade{} level of played',
        '{C:attention}poker hand{} upon {C:attention}scoring{}'
   }
 },
atlas = 'colors',
	pos = { x = 1, y = 0 },
	calculate = function(self, card, context)
		if context.final_scoring_step and context.cardarea == G.play then
			return {
				level_up = true
			}
		end
	end
}

--Yellow
SMODS.Enhancement{
 key = 'yellow',
 loc_txt = {
    name = 'Yellow',
    text = {
        '{X:money,C:white}X1.2{} Dollars when {C:attention}scored{}.'
    }
 },
atlas = 'colors',
	pos = { x = 2, y = 0 },
	config = { extra = { dollars = 1.2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars } }
	end,
	calculate = function(self, card, context)
		if context.main_scoring and context.cardarea == G.play then
			return {
                  dollars = ((G.GAME.dollars * card.ability.extra.dollars) - G.GAME.dollars)
      }
		end
	end
}

--Green
SMODS.Enhancement{
 key = 'green',
 loc_txt = {
    name = 'Green',
    text = {
        '{C:green}1 in 4 chance{} to add',
        'a random card with',
        'an {C:attention}Edition{} to your deck.'
    }
 },
atlas = 'colors',
	pos = { x = 0, y = 1 },
	config = { extra = { odds = 4 } },
	loc_vars = function(self, info_queue, card)
		-- return { vars = { G.GAME.probabilities.normal } }
        local GreenIsNotACreativeColor, GreenIsACreativeColor = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'greenProbCheck')
        return {vars = {GreenIsNotACreativeColor, GreenIsACreativeColor } }
	end,
	calculate = function(self, card, context)
		if context.main_scoring and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'Green Card', 1, card.ability.extra.odds, 'greenProbCheck') then
			local _card = create_playing_card ({
				front = pseudorandom_element(G.P_CARDS, pseudoseed('colr_green')), -- Note to Arya: This is fine in 0711a. YIPPEE!
				center = G.P_CENTERS.c_base
			}, G.discard, true, nil, {G.C.SECONDARY_SET.Enhanced}, true)
			_card:set_edition(poll_edition("colr_green", nil, nil, true))
			return {
				func = function()
					G.E_MANAGER:add_event(Event({
						func = function()
							G.hand:emplace(_card)
							_card:start_materialize()
							G.GAME.blind:debuff_card(_card)
							G.hand:sort()
							return true
							end
						}))
						SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
				end
			}
		end
	end
}

--Blue
SMODS.Enhancement{
 key = 'blue',
 loc_txt = {
    name = 'Blue',
    text = {
        '{X:chips,C:white}X#1#{} {C:chips}Chips{}'
    }
 },
 atlas = 'colors',
 pos = { x = 1, y = 1 },
 config = {
  x_chips = 2
 },
 loc_vars = function(self, info_queue, card)
  return { vars = { card.ability.x_chips } }
 end
}

--Purple
SMODS.Enhancement{
 key = 'purple',
 loc_txt = {
    name = 'Purple',
    text = {
        'Gives a {C:attention}random card{}',
        '{C:attention}held in hand{} a',
        '{C:purple}Purple Seal{} upon {C:attention}scoring{}',
        '{C:inactive}Requires a card in hand to work,{}', 
        '{C:inactive}otherwise a crash occurs!{}'
    }
 },
atlas = 'colors',
	pos = { x = 2, y = 1 },
	config = { extra = { seal = "Purple", random = 1 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
		return { vars = { card.ability.extra.random } }
	end,
	calculate = function(self, card, context)
		local card_to_seal = pseudorandom_element(G.hand.cards, 'random_purple')
		if context.main_scoring and context.cardarea == G.play then
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.4,
				func = function()
					play_sound('tarot1')
					card_to_seal:set_seal(card.ability.extra.seal, nil, true)
					card_to_seal:juice_up(0.3, 0.5)
					return true
				end
			}))
		end
	end
}

-- Black Enhancement via Arya
SMODS.Enhancement {
    key = "black",
    loc_txt = {
        name = "Black",
        text = {
            "If applied on a {C:spades}Spade{} or {C:clubs}Club{} card: {X:chips,C:white}x3{} {C:chips}Chips{}",
            "If applied on a {C:hearts}Heart{} or {C:diamonds}Diamond{} card: {C:chips}+30 Chips{}"
        }
    },
    atlas = 'colors',
    pos = { x = 1, y = 2},
    loc_vars = function(self, info_queue, card)
      return { vars = { card.ability.extra.chips, card.ability.extra.x_chips } }
    end,
    config = { extra = { chips = 30, x_chips = 3 } },
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            if card:is_suit("Hearts") or card:is_suit("Diamonds") then
                return {
                    chips = card.ability.extra.chips
                }
            else
                return {
                    x_chips = card.ability.extra.x_chips
                }
            end
        end
    end
}

-- Brown Enhancement via Arya
SMODS.Enhancement {
    key = "brown",
    loc_txt = {
        name = "Brown",
        text = {
            "Summons a random {C:tarot}Tarot{}",
            "card when {C:attention}scored{}",
            "{C:inactive}Doesn't require room!{}"
        }
    },
    atlas = "colors",
    pos = { x = 2, y = 2 },
    loc_vars = function(self, info_queue, card)
      return { }
    end,
    config = { extra = { } },
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            SMODS.add_card({set = "Tarot"})
        end
    end
}

-- Ivory Enhancement via Arya
SMODS.Enhancement {
    key = "ivory",
    loc_txt = {
        name = "Ivory",
        text = {
            "If applied on a {C:spades}Spade{} or {C:clubs}Club{} card: {C:chips}+30 Chips{}",
            "If applied on a {C:hearts}Heart{} or {C:diamonds}Diamond{} card: {X:chips,C:white}x3{} {C:chips}Chips{}"
        }
    },
    atlas = 'colors',
    pos = { x = 0, y = 3},
    loc_vars = function(self, info_queue, card)
      return { vars = { card.ability.extra.chips, card.ability.extra.x_chips } }
    end,
    config = { extra = { chips = 30, x_chips = 3 } },
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            if card:is_suit("Clubs") or card:is_suit("Spades") then
                return {
                    chips = card.ability.extra.chips
                }
            else
                return {
                    x_chips = card.ability.extra.x_chips
                }
            end
        end
    end
}

-- Painted Joker coded in via Arya
SMODS.Atlas {
    key = 'painted_joker',
    path = 'paintedjoker.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "painted_joker",
    loc_txt = {
        name = 'Painted Joker',
        text = {
            "{C:mult}+3 Mult{} when any card", 
            "with a {C:attention}Paint{} enhancement is played.",
        }
    },
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    atlas = 'painted_joker',
    pos = { x = 0, y = 0 },
    config = { extra = { mult = 3 } },
    loc_vars = function(self, info_queue, card)
      return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, "m_colr_red") or SMODS.has_enhancement(context.other_card, "m_colr_orange") or SMODS.has_enhancement(context.other_card, "m_colr_yellow") or SMODS.has_enhancement(context.other_card, "m_colr_green") or SMODS.has_enhancement(context.other_card, "m_colr_blue") or SMODS.has_enhancement(context.other_card, "m_colr_purple") or SMODS.has_enhancement(context.other_card, "m_colr_pink") or SMODS.has_enhancement(context.other_card, "m_colr_black") or SMODS.has_enhancement(context.other_card, "m_colr_brown") or SMODS.has_enhancement(context.other_card, "m_colr_ivory") then -- Arya: This method is so ugly, but it works and was suggested in #modding-dev. I have no reason to argue with it.
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end

}

--Paint Consumable Type
SMODS.ConsumableType{
    key = 'paint',
    primary_colour = HEX("FF0000"),
    secondary_colour = HEX("FF0000"),
    loc_txt = {
        name = 'Paint',
        collection = 'Paint Cards',
    },
}

--Red Paint
SMODS.Atlas{
    key = 'red_paint',
    path = 'redpaint.png',
    px = 71,
    py = 95
}

SMODS.Consumable{
    key = 'red_paint',
    set = 'paint',
    loc_txt = {
        name = 'Red Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Red{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'red_paint',
    pos = {x = 0, y = 0},
    config = { max_highlighted = 2, mod_conv = 'm_colr_red' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('FF0000') }
            }
        }
	end
}

--Orange Paint
SMODS.Atlas{
    key = 'orange_paint',
    path = 'orangepaint.png',
    px = 71,
    py = 95
}
SMODS.Consumable{
    key = 'orange_paint',
    set = 'paint',
    loc_txt = {
        name = 'Orange Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Orange{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'orange_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_orange' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('FFA500') }
            }
        }
	end
}

--Yellow Paint
SMODS.Atlas{
    key = 'yellow_paint',
    path = 'yellowpaint.png',
    px = 71,
    py = 95
}
SMODS.Consumable{
    key = 'yellow_paint',
    set = 'paint',
    loc_txt = {
        name = 'Yellow Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Yellow{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'yellow_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_yellow' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('EFCC00') }
            }
        }
	end
}

--Green Paint
SMODS.Atlas{
    key = 'green_paint',
    path = 'greenpaint.png',
    px = 71,
    py = 95
}
SMODS.Consumable{
    key = 'green_paint',
    set = 'paint',
    loc_txt = {
        name = 'Green Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Green{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'green_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_green' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('00FF00') }
            }
        }
	end
}

--Blue Paint
SMODS.Atlas{
    key = 'blue_paint',
    path = 'bluepaint.png',
    px = 71,
    py = 95
}
SMODS.Consumable{
    key = 'blue_paint',
    set = 'paint',
    loc_txt = {
        name = 'Blue Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Blue{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'blue_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_blue' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('0000FF') }
            }
        }
	end
}

--Purple Paint
SMODS.Atlas{
    key = 'purple_paint',
    path = 'purplepaint.png',
    px = 71,
    py = 95
}
SMODS.Consumable{
    key = 'purple_paint',
    set = 'paint',
    loc_txt = {
        name = 'Purple Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Purple{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'purple_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_purple' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('7800FF') }
            }
        }
	end
}

-- Pink Enhancement
SMODS.Enhancement {
    key = 'pink',
    loc_txt = {
        name = 'Pink',
        text = {
            '{X:mult,C:white}X2{} {C:mult}Mult{} and {X:chips,C:white}X2{} {C:chips}Chips{},',
            'but only on a {C:attention}Boss Blind{}'
        }
    },
    atlas = 'colors',
    pos = { x = 0, y = 2 },
    config = {
       extra = {
        x_chips = 2,
        x_mult = 2
       },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.x_chips, card.ability.x_mult } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play and G.GAME.blind.boss then
            return { xchips = card.ability.extra.x_chips, xmult = card.ability.extra.x_mult }
        end
    end
}

-- Black Paint
SMODS.Atlas{
    key = 'black_paint',
    path = 'blackpaint.png',
    px = 71,
    py = 95
}
SMODS.Consumable{
    key = 'black_paint',
    set = 'paint',
    loc_txt = {
        name = 'Black Paint Bucket',
        text = {
            'Gives 2 cards the {C:black}Black{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'black_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_black' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
	end
}

-- Brown Paint
SMODS.Atlas{
    key = 'brown_paint',
    path = 'brownpaint.png',
    px = 71,
    py = 95
}
SMODS.Consumable{
    key = 'brown_paint',
    set = 'paint',
    loc_txt = {
        name = 'Brown Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Brown{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'brown_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_brown' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('964B00') }
            }
        }
	end
}

-- Black Paint
SMODS.Atlas{
    key = 'black_paint',
    path = 'blackpaint.png',
    px = 71,
    py = 95
}

SMODS.Consumable{
    key = 'black_paint',
    set = 'paint',
    loc_txt = {
        name = 'Black Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Black{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'black_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_black' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('000000') }
            }
        }
	end
}

-- Pink Paint
SMODS.Atlas{
    key = 'pink_paint',
    path = 'pinkpaint.png',
    px = 71,
    py = 95
}

SMODS.Consumable{
    key = 'pink_paint',
    set = 'paint',
    loc_txt = {
        name = 'Pink Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Pink{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'pink_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_pink' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('FF00FF') }
            }
        }
	end
}

-- Pink Paint
SMODS.Atlas{
    key = 'ivory_paint',
    path = 'ivorypaint.png',
    px = 71,
    py = 95
}

SMODS.Consumable{
    key = 'ivory_paint',
    set = 'paint',
    loc_txt = {
        name = 'Ivory Paint Bucket',
        text = {
            'Gives 2 selected cards the {V:1}Ivory{} enhancement.'
        }
    },
        cost = 3,
        discovered = true,
        atlas = 'ivory_paint',
        config = { max_highlighted = 2, mod_conv = 'm_colr_ivory' },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                colours = { HEX('f2efde') }
            }
        }
	end
}

--Random Paint Bucket
SMODS.Atlas{
    key = 'randompaint',
    path = 'randompaint.png',
    px = 71,
    py = 95
}

SMODS.Booster{
    key = 'randompaint',
    loc_txt = {
        name = 'Random Paint Pack',
        group_name = "Random Paint Buckets", -- Arya: Genuinely, I do not know why this doesn't work. Curse you, John SMODS.
        text = {
            'Choose {C:attention}1{} of up to {C:attention}3{}',
            '{C:attention}Paint Buckets{} to be',
            'used immediately.'
        },
    },
    config = {extra = 3, choose = 1},
    draw_hand = true,
    atlas = 'randompaint',
    pos = { x = 0, y = 0 },
    create_card = function(self, card)
        return SMODS.create_card({area = G.pack_cards, no_edition = true, skip_materialize = true, set = "paint"})
    end,
    weight = 1,
    cost = 4,
    group_key = 'grouprandompaint'
}

