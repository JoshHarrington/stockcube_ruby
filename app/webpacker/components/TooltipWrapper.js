import React, {useState} from "react"
import * as classNames from "classnames"
import PropTypes from 'prop-types';

const TooltipWrapper = ({text, className, width, children}) => {
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
			<div className={classNames("absolute bg-black text-white text-xs rounded p-3 right-0 bottom-full text-center", {"hidden": !inHover}, {[widthString]: !!widthVar})}
			style={{left: "50%", bottom: "calc(100% + .5rem"}}>
				{text}
				<svg className="absolute text-black h-2 w-full left-0 bottom-0 -mb-2" x="0px" y="0px" viewBox="0 0 255 255" xmlSpace="preserve"><polygon className="fill-current" points="0,0 127.5,127.5 255,0"/></svg>
			</div>
		</div>

	)
}

TooltipWrapper.propTypes = {
	text: PropTypes.string,
	width: PropTypes.oneOf([24, 32, 40, 48, 64]),
	className: PropTypes.string
}

export default TooltipWrapper
