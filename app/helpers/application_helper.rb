module ApplicationHelper
	include PlannerShoppingListHelper
	include UnitsHelper
	def icomoon(name, viewBox='')
		image_png_name = name.to_s + '.png'
		return '<svg class="icomoon-icon icon-'.html_safe + name + '"'.html_safe + (!viewBox.empty? ? ' viewBox="'.html_safe + viewBox.to_s.html_safe + '"'.html_safe : '' ) + '><use xlink:href="'.html_safe + asset_pack_path('assets/icons/symbol-defs.svg') + '#icon-'.html_safe + name + '"></use></svg>'.html_safe + '<img class="icon-png" src="'.html_safe + asset_pack_path('assets/png-icons/' + image_png_name ) +'"></img>'.html_safe
	end
	def svg_icon_path(name)
		return asset_pack_path('assets/icons/symbol-defs.svg') + '#icon-'.html_safe + name
	end
	def png_icon_path(name)
		image_png_name = name.to_s + '.png'
		return asset_pack_path('assets/png-icons/' + image_png_name)
	end
	def icomoon_png(name)
		image_png_name = name.to_s + '.png'
		return '<img class="icon-png" src="'.html_safe + asset_pack_path('assets/png-icons/' + image_png_name ) +'"></img>'.html_safe
	end
	def large_svg(name, viewBox='')
		return '<svg class="large-svg '.html_safe + name + '"'.html_safe + (!viewBox.empty? ? ' viewBox="'.html_safe + viewBox.to_s.html_safe + '"'.html_safe : '' )  + '><use xlink:href="'.html_safe + asset_pack_path('assets/icons/' + name + '.svg') + '#'.html_safe + name + '"></use></svg>'.html_safe
	end
	def random_name
		names = ["🤖 Ursula K. Le Guin",
			"🤖 Virginia Woolf",
			"🤖 Louisa May Alcott",
			"🤖 Harper Lee",
			"🤖 Charlotte Brontë",
			"🤖 Emily Brontë",
			"🤖 Elizabeth Strout",
			"🤖 Jane Austen",
			"🤖 Toni Morrison",
			"🤖 Geraldine Brooks",
			"🤖 George Eliot",
			"🤖 Margaret Atwood",
			"🤖 Gertrude Stein",
			"🤖 Edith Wharton",
			"🤖 Donna Tartt",
			"🤖 J.K. Rowling",
			"🤖 Joyce Carol Oates",
			"🤖 Anne Tyler",
			"🤖 Annie Proulx",
			"🤖 Alice Munro",
			"🤖 Octavia Butler",
			"🤖 Alice Walker",
			"🤖 Harriet Beecher Stowe",
			"🤖 Judy Blume",
			"🤖 Marilynne Robinson",
			"🤖 PD James",
			"🤖 Georgette Heyer",
			"🤖 Willa Cather",
			"🤖 Zadie Smith",
			"🤖 Chimamanda Ngozi Adichie",
			"🤖 Doris Lessing",
			"🤖 Mary Shelley",
			"🤖 Madeleine L'Engle",
			"🤖 Roxane Gay",
			"🤖 Angela Carter",
			"🤖 Elena Ferrante",
			"🤖 Joan Didion",
			"🤖 Jeanette Winterson ",
			"🤖 Lucy Maud Montgomery",
			"🤖 Hilary Mantel",
			"🤖 Louise Erdrich ",
			"🤖 Jhumpa Lahiri",
			"🤖 Connie Willis",
			"🤖 Isabel Allende",
			"🤖 Elizabeth Gilbert",
			"🤖 Diana Gabaldon",
			"🤖 Sarah Waters",
			"🤖 Eleanor Catton",
			"🤖 Nadine Gordimer",
			"🤖 Karen Russell",
			"🤖 Ruth Ozeki",
			"🤖 Edna O'Brien",
			"🤖 Miriam Toews",
			"🤖 Kate Atkinson",
			"🤖 Ann Patchett ",
			"🤖 Emma Donoghue",
			"🤖 Barbara Kingsolver",
			"🤖 Agatha Christie",
			"🤖 Sue Monk Kidd",
			"🤖 Penelope Lively ",
			"🤖 Jennifer Egan ",
			"🤖 Arundhati Roy",
			"🤖 A.S. Byatt",
			"🤖 Kiran Desai",
			"🤖 Keri Hulme",
			"🤖 Penelope Fitzgerald",
			"🤖 Iris Murdoch",
			"🤖 Emma Straub",
			"🤖 Yaa Gyasi",
			"🤖 Emily St. Mandel",
			"🤖 Sylvia Plath",
			"🤖 Zora Neale Hurston",
			"🤖 Lauren Groff",
			"🤖 Maria Semple",
			"🤖 Ami McKay",
			"🤖 Ali Smith",
			"🤖 Meg Wolitzer",
			"🤖 Miranda July",
			"🤖 Tayari Jones",
			"🤖 Helen Oyeyemi",
			"🤖 Daphne du Maurier",
			"🤖 NoViolet Bulawayo",
			"🤖 Jesmyn Ward",
			"🤖 Julia Glass",
			"🤖 Susan Sontag",
			"🤖 Alice McDermott",
			"🤖 Flannery O'Connor",
			"🤖 Evie Wyld",
			"🤖 Anna Funder",
			"🤖 Ann-Marie MacDonald",
			"🤖 Cynthia Bond",
			"🤖 Carol Shields",
			"🤖 Jane Smiley ",
			"🤖 Alison Lurie",
			"🤖 Edwidge Danticat",
			"🤖 Rachel Kushner",
			"🤖 Claire Messud",
			"🤖 Amy Tan",
			"🤖 Celeste Ng",
			"🤖 Elizabeth Poliner"]
		fresh_names = names - User.all.map(&:name).uniq
		return fresh_names.sample
	end
	def link_current_page_element(page_path, link_string, optional_section = nil)
		section = request.path_parameters[:controller]
		if current_page?(page_path) && !request.parameters.has_key?(:search)
			return '<li class="current_page"><span class="fake_link">'.html_safe + link_string.html_safe + '</span></li>'.html_safe
		elsif page_path.to_s.include?(section) || (optional_section != nil ? section.to_s.include?(optional_section) : false)
			return '<li class="current_section">'.html_safe + link_to(link_string, page_path) + '</li>'.html_safe
		else
			return '<li>'.html_safe + link_to(link_string, page_path) + '</li>'.html_safe
		end
	end
	def shopping_list_class
		return unless current_user && current_user.planner_recipes.select{|pr| pr.date > Date.current - 1.day && pr.date < Date.current + 7.day} && !(params[:controller] == 'planner' && params[:action] == 'list')
		if current_user.planner_recipes.select{|pr| pr.date > Date.current - 1.day && pr.date < Date.current + 7.day}.length > 0 && checked_portions != shopping_list_portions.length
			return 'shopping_list_open'
		end
	end

	def shopping_list_count
		if total_portions > 0
			return checked_portions.to_s + '/' + total_portions.to_s
		else
			return false
		end
	end

	def logged_in?
		user_signed_in?
	end
end
