Class {
	#name : #LoggerTransformationTool,
	#superclass : #Object,
	#instVars : [
		'model'
	],
	#category : #'BlogPost-Transformation'
}

{ #category : #'as yet unclassified' }
LoggerTransformationTool class >> onModel: aMooseModel [

	^ self new
		  model: aMooseModel;
		  yourself
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> createNewReceiverNode [

	^ FASTJavaIdentifier new
		  name: 'ArgoLogger';
		  yourself
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> createWrappersForCandidateMethods: aCollectionOfFamixJavaMethods [

	^ aCollectionOfFamixJavaMethods collect: [ :fjm | 
		  | fastMethod |
		  fjm generateFastIfNotDoneAndBind.
		  fastMethod := fjm fast.
		  JavaMethodToTransformWrapper
			  forFamixMethod: fjm
			  andFAST: fastMethod ]
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> fetchAllFastNodesUsingCarrefour [

	^ self fetchLogErrorMethodInvocations collect: [ :mi | 
		  self fetchFastNodeForFamixInvocation: mi ]
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> fetchAllFastNodesUsingMotion [

	^ self fetchLogErrorMethodInvocations collect: [ :mi | 
		  mi sender generateFastIfNotDoneAndBind.
		  self motionQueryForFastMethod: mi sender fast ]
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> fetchFastNodeForFamixInvocation: anInvocation [

	"building and binding the FAST of the invocating method"
	anInvocation sender generateFastIfNotDoneAndBind.
	
	"returning the actual node of the method invocation, our target"
	^ anInvocation fast 
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> fetchLogErrorMethodInvocations [

	^ self fetchLogErrorMethods flatCollect: [ :m | 
		  m incomingInvocations ]
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> fetchLogErrorMethodInvocationsSenders [

	^ self fetchLogErrorMethodInvocations collect: [ :mi | mi sender ]
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> fetchLogErrorMethods [

	^ model allModelMethods select: [ :m | m name = 'logError' ]
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> findAndTransformAllLogErrorInvocations [

	| wrappers |
	wrappers := self createWrappersForCandidateMethods:
		            self fetchLogErrorMethodInvocationsSenders.

	^ wrappers do: [ :w | self transformMethod: w ]
]

{ #category : #accessing }
LoggerTransformationTool >> model [

	^ model
]

{ #category : #accessing }
LoggerTransformationTool >> model: anObject [

	model := anObject
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> motionQueryForFastMethod: aFASTJavaMethodEntity [

	| query |
	query := FASTJavaMethodEntity
	         % { (#'children*' <=> FASTJavaMethodInvocation
		          % { (#name <=> 'logError') } as: #logErrorInvocation) }
		         collectBindings: { 'logErrorInvocation' }
		         for: aFASTJavaMethodEntity.

	^ query first at: 'logErrorInvocation'
]

{ #category : #'as yet unclassified' }
LoggerTransformationTool >> transformMethod: aJavaMethodWrapper [

	| methodInvocationNode |
	methodInvocationNode := self motionQueryForFastMethod:
		                        aJavaMethodWrapper transformedFastMethod.
	
	methodInvocationNode receiver: self createNewReceiverNode
]
