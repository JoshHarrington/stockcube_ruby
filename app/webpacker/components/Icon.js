import React from "react"
import SVG from '../icons/symbol-defs.svg'

function Icon(props) {
  const name = props.name
  const className = props.className
  return (
    <svg className={className}><use className="fill-current" xlinkHref={`${SVG}#icon-${name}`} /></svg>
  )
}

export default Icon
