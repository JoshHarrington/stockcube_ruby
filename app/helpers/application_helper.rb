module ApplicationHelper
	def icomoon(name)
		image_png_name = 'PNG/' + name.to_s + '.png'
		return '<svg class="icomoon-icon icon-'.html_safe + name + '"><use xlink:href="'.html_safe + asset_path('symbol-defs.svg') + '#icon-'.html_safe + name + '"></use></svg>'.html_safe + '<img class="icon-png" src="'.html_safe + asset_path( image_png_name ) +'"></img>'.html_safe
	end
	def large_svg(name)
		return '<svg class="large-svg '.html_safe + name + '"><use xlink:href="'.html_safe + asset_path( name + '.svg') + '#'.html_safe + name + '"></use></svg>'.html_safe
	end
	def domain_check(subdomain_string)
		full_domain = request.host
		if full_domain.to_s.include? '.'
			full_domain = full_domain.split('.')
			subdomain = full_domain[0]
			if subdomain.to_s == subdomain_string.to_s
				return true
			end
		end
	end
end
