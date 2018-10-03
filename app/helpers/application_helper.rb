module ApplicationHelper
	def icomoon(name)
		image_png_name = 'PNG/' + name.to_s + '.png'
		return '<svg class="icomoon-icon icon-'.html_safe + name + '"><use xlink:href="'.html_safe + asset_path('symbol-defs.svg') + '#icon-'.html_safe + name + '"></use></svg>'.html_safe + '<img class="icon-png" src="'.html_safe + asset_path( image_png_name ) +'"></img>'.html_safe
	end
	def large_svg(name)
		return '<svg class="large-svg '.html_safe + name + '"><use xlink:href="'.html_safe + asset_path( name + '.svg') + '#'.html_safe + name + '"></use></svg>'.html_safe
	end
end
