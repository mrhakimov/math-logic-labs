{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE Strict #-}
{
module Parser where
import Lexer
}

%name parser Expression
%name parseStatement Statement
%tokentype { Token }
%error { parseError }

%token
    var                 { TVariable $$ }
    "|-"                { TCarriage }
    "->"                { TImplication }
    ','                 { TComma }
    '|'                 { TDisjunction }
    '&'                 { TConjunction }
    '!'                 { TNegation }
    '('                 { TOpeningBracket }
    ')'                 { TClosingBracket }

%%

Statement   : Context "|-" Expression                     { Statement $1 $3}

Context     : Expression                                  { [$1] }
            | Context ',' Expression                      { $3 : $1 }
            | {- empty context -}                         { [] }

Expression  : Disjunction                                 { $1 }
            | Disjunction "->" Expression                 { Implication $1 $3 }

Disjunction : Conjunction                                 { $1 }
            | Disjunction '|' Conjunction                 { Disj $1 $3 }

Conjunction : Negation                                    { $1 }
            | Conjunction '&' Negation                    { Conj $1 $3 }

Negation    : '!' Negation                                { NegationNot $2 }
            | var                                         { Variable $1 }
            | '(' Expression ')'                          { $2 }

{
parseError :: [Token] -> a
parseError _ = error "Parse error"

data Statement = Statement { getHypotheses :: [Expression], getResult :: Expression } deriving Show

data Expression = Implication Expression Expression
                | Disj Expression Expression
                | Conj Expression Expression
                | NegationNot Expression
                | Variable String
                deriving (Ord, Eq)

instance Show Expression where
    show (Implication left right)       = "(" ++ (show left) ++ "->" ++ (show right) ++ ")"
    show (Disj left right)              = "(" ++ (show left) ++ "|" ++ (show right) ++ ")"
    show (Conj left right)              = "(" ++ (show left) ++ "&" ++ (show right) ++ ")"
    show (NegationNot expression)       = "(!" ++ (show expression) ++ ")"
    show (Variable variable)            = variable
}
