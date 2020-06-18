import React, {useState} from "react"
import * as classNames from "classnames"
import PropTypes from 'prop-types'

const TooltipWrapper = ({text, className, width, position, hidden, children}) => {
	const [inHover, setHover] = useState(false)

	const widthVar = !!(!!width && typeof width === "number") ? width : 24
	const halfWidth = widthVar / 2
	const widthString = `w-${widthVar} -ml-${halfWidth}`

	return (
		<div className={classNames(className, "relative")}
			onMouseEnter={() => setHover(true)}
			onMouseLeave={() => setHover(false)}
		>
			{children}
			<div className={classNames("absolute bg-black text-white text-xs rounded p-3 right-0 bottom-full text-center z-10", {"hidden": !inHover || hidden}, {[widthString]: !!widthVar})}
			style={{left: "50%", bottom: !!(!position || position === "top") && "calc(100% + .5rem", top: !!(!!position && position === "bottom") && "calc(100% + .5rem" }}>
				{text}
				<svg className={classNames("absolute text-black h-2 w-full left-0", {"top-0 -mt-2 transform rotate-180": !!position && position === "bottom"}, {"bottom-0 -mb-2": !position || position === "top"})} x="0px" y="0px" viewBox="0 0 255 255" xmlSpace="preserve"><polygon className="fill-current" points="0,0 127.5,127.5 255,0"/></svg>
			</div>
		</div>

	)
}

TooltipWrapper.propTypes = {
	position: PropTypes.oneOf(['top', 'bottom']),
	text: PropTypes.string,
	width: PropTypes.oneOf([24, 32, 40, 48, 64]),
	className: PropTypes.string,
	hidden: PropTypes.bool
}

export default TooltipWrapper
