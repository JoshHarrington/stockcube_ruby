module ApplicationHelper
	def icomoon(name)
		return '<svg class="icomoon-icon icon-'.html_safe + name + '"><use xlink:href="'.html_safe + asset_path('symbol-defs.svg') + '#icon-'.html_safe + name + '"></use></svg>'.html_safe
	end
end
