import React from "react"
import * as classNames from "classnames"

const Spinner = ({className}) => (
	<span className={classNames("spinner ease-linear rounded-full border-2 border-white border-solid inline-block", className)} />
)

export default Spinner
