Class {
	#name : #BaselineOfMooseBlogPostTransformation,
	#superclass : #BaselineOf,
	#category : #BaselineOfMooseBlogPostTransformation
}

{ #category : #baselines }
BaselineOfMooseBlogPostTransformation >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			package: 'BlogPost-Transformation' ]
]
