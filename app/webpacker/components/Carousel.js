import React from "react"
import * as classNames from "classnames"
import PropTypes from 'prop-types';

import Carousel from '@brainhubeu/react-carousel'
import Icon from "./Icon"

/// Should be importing from node_modules
/// instead is included in the css in vendor/brainhub-carousel.scss
// import '@brainhubeu/react-carousel/lib/style.css'

const PrevButton = ({disabled}) => {
	return (
		<button className={classNames("border-0 p-2 text-white", {"bg-primary-500": !disabled}, {"bg-primary-100 cursor-not-allowed": !!disabled})}><Icon name="navigate_before" className="w-8 h-8" /></button>
	)
}

PrevButton.propTypes = {
	disabled: PropTypes.bool
}

const NextButton = ({disabled}) => {
	return (
		<button className={classNames("border-0 p-2 text-white", {"bg-primary-500": !disabled}, {"bg-primary-100 cursor-not-allowed": !!disabled})}><Icon name="navigate_next" className="w-8 h-8" /></button>
	)
}

NextButton.propTypes = {
	disabled: PropTypes.bool
}


const Standard = props => {
	const { children } = props
	return (
		<Carousel
			slidesPerPage={4}
			arrows
			infinite={false}
			keepDirectionWhenDragging
			breakpoints={{
				640: {
					slidesPerPage: 1,
					arrows: false
				},
				768: {
					slidesPerPage: 2,
					arrows: true
				},
				1024: {
					slidesPerPage: 3,
					arrows: true
				}
			}}
			arrowLeft={<PrevButton />}
			arrowLeftDisabled={<PrevButton disabled />}
			arrowRight={<NextButton />}
			arrowRightDisabled={<NextButton disabled />}
			addArrowClickHandler
		>{children}</Carousel>
	)
}

export default Standard
