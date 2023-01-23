%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>
#include "y.tab.h"
#include <vector>
#include <algorithm>
#include <string.h>
extern FILE *yyin;

using namespace std;
extern int lineCount;
int tab_counter=0;
int tab_Cur=0;
int tab_Pre=0;

int if_counter=0;

int else_counter=0;
bool in_if=false;
bool if_else_state=false;

bool cmpr(string a,string b){return a<b;}
string tab_print="";

vector<string> data_vector_if;
vector<string> data_vector;
vector<string>data_name_int;
vector<string>data_name_flt;
vector<string>data_name_str;
vector<string> out_put;

map<string,string> var_type;
map<string,string>data_value;

string dec;

string output;
int yylex();



%}
%union
{	
	int number;
	char * str;
}

%token  EQUAL COLON  IF ELIF ELSE TAB NEXT_LINE
%token <str> OPERATOR INTEGER FLOAT IDENTIFIER COMPARE STRING
%type <str>  types
%type <str> operations
%type <str> compare
%type <str> declare
%type <str> ifelse
%type <str> operations_if
%type <str> types_if

%type <str> tabs


%%
program:stmts
	{
	
	cout<<"void main()\n{\n";

	tab_print="\t";

	sort(data_name_int.begin(),data_name_int.end(),cmpr);
	if(data_name_int.size()!=0){
		cout<<tab_print<<"int ";
		int j=1;
		for(int i=0;i<data_name_int.size();i++){
			cout<<data_name_int[i];
			if(j!=data_name_int.size()){
			cout<<",";
			j++;
			}
			
		}
		cout<<";"<<endl;
	}
	sort(data_name_flt.begin(),data_name_flt.end(),cmpr);
	if(data_name_flt.size()!=0){
		
		cout<<tab_print<<"float ";
		
		int j=1;
		for(int i=0;i<data_name_flt.size();i++){
			cout<<data_name_flt[i];
			if(j!=data_name_flt.size()){
			cout<<",";
			j++;
			}
			
		}
		cout<<";"<<endl;
	}
	sort(data_name_str.begin(),data_name_str.end(),cmpr);
	if(data_name_str.size()!=0){
		
		cout<<tab_print<<"string ";
		
		int j=1;
		for(int i=0;i<data_name_str.size();i++){
			cout<<data_name_str[i];
			if(j!=data_name_str.size()){
			cout<<",";
			j++;
			}
			
		}
		cout<<";"<<endl;
	}
//	cout<<"\n"<<output<<endl;
	cout<<endl;
	for(int i=0;i<out_put.size();i++){
		cout<<tab_print<<out_put[i];
			}
			
		
	
	cout<<"\n}"<<endl;
	
	}
	;
//---------------------
stmts: 
	
	tabs stmt
	{	
		
		
		if(!if_else_state){
			if (tab_Pre<tab_counter)
			{
				cout<<"tab inconsistency in line "<<lineCount+1<<endl;
				exit(1);
				//output=tab_print+output;
			}
			for(int t=0;t<tab_counter;t++){
				tab_print+="\t";
			}
			string temp=out_put.back();
			out_put.erase(out_put.end());
			out_put.push_back(tab_print+temp);
			
			//out_put.insert(out_put.end(),tab_print);
			tab_print="";
			tab_Pre=tab_counter;
		}
		else{
			if((tab_Pre)>(if_counter))
			{
				cout<<"tab inconsistency in line "<<lineCount++<<endl;
				exit(1);
			}
			
			else{
			for(int t=0;t<tab_counter+if_counter-2;t++){
				tab_print+="\t";
			}
			
			string temp=out_put.back();
			out_put.erase(out_put.end());
			out_put.push_back(tab_print+temp);
			tab_print="";
			tab_Pre+=tab_counter;}
		}
		
		
		
	}
	|
	stmt
	{
		
		
	}
	|
	stmts NEXT_LINE stmts
	{
		//out_put.push_back("\n");
		
	}
	
	
	
	
	;
//------------------------------------
stmt:
	
	declare
	{	
		
		if_else_state=false;
		//output=output+tab_print+string($1)+";\n";
		
		out_put.push_back(string($1)+";\n");
		
		
		
		//tab_print="";
	}
	
	|
	ifelse
	{
		if_else_state=true;
		/*for(int t=0;t<tab_counter;t++){
		tab_print+="\t1";
		}*/
		//output=output+tab_print+string($1)+"\n";
		
		
		out_put.push_back(string($1)+"\n{");
	
	}
	|
	
	;
//--------------------------------
ifelse:
	IF compare COLON  
	{
		if_counter++;
		tab_Pre++;
		in_if=true;
		string temp = string("if( ")+string($2)+string(" )\n");
		
		$$=strdup(temp.c_str());
		
	}
	
	|
	ELIF compare COLON  
	{	
		/*if(if_counter==0){
			cout<<"else without if in line "<<lineCount<<endl;
			exit(1);
		}
		else if(!in_if){
			cout<<"elif after else in line "<<lineCount<<endl;
			exit(1);
		}
		*/
		tab_Pre++;
		string temp = "else if( "+string($2)+" )\n";
		
		$$=strdup(temp.c_str());
		
	}
	
	|
	ELSE COLON  
	{	
		in_if=false;
		tab_Pre++;
		if(if_counter==0){
			cout<<"else without if in line "<<++lineCount<<endl;
			exit(1);
		}
		
		
		string temp = "else\n";
		
		$$=strdup(temp.c_str());
	}
	
	;
//--------------------------------


compare: operations_if COMPARE operations_if
	{	
		string temp2=data_vector_if.back();
		data_vector_if.erase(data_vector_if.end());
		string temp1=data_vector_if.back();
		data_vector_if.erase(data_vector_if.end());
		if((temp2=="str" && temp1!="str")||(temp2!="str" && temp1=="str")){
			 cout << "comparison type mismatch in line "<<++lineCount<<endl;
			 exit(1);
		}
		string comb=string($1)+" "+string($2)+" "+string($3);
		
		$$=strdup(comb.c_str());
	}
	
	;



//---------------------------
operations_if:
	IDENTIFIER
	{
		string comb=string($1);
		string temp=var_type[$1];
		
		data_vector_if.push_back(string(temp));
		
		comb=comb+"_"+string(temp);
		
      		$$=strdup(comb.c_str());
	
	}
	|
	types_if
	{
		string comb=string($1);
		string temp=data_vector_if.back();
		data_vector_if.erase(data_vector_if.end());
		data_vector.push_back(string(temp));
		$$=strdup(comb.c_str());
	}
	|
	operations_if OPERATOR operations_if
	{
		string comb=string($1)+" "+string($2)+" "+string($3);
		string temp2=data_vector_if.back();
		data_vector_if.erase(data_vector_if.end());
		string temp1=data_vector_if.back();
		data_vector_if.erase(data_vector_if.end());
		
		
		if(temp1==temp2 ){
			
			data_vector_if.push_back(temp1);
		}
		else if(temp1=="int" && temp2=="flt"){
			 
			data_vector_if.push_back(temp2.c_str());
			
		}
		else if(temp1=="flt" && temp2=="int"){
			
			data_vector_if.push_back(temp1.c_str());

		}
		else{
			cout<<"type mismatch in line "<<++lineCount<<endl;
			exit(1);
		}
		
		$$=strdup(comb.c_str());
	}
	;

//---------------------------



declare:
	IDENTIFIER EQUAL operations 
	{
		string comb=string($3);
		
		data_value[$1]=data_vector.back();
		
		
		
		
		string last=string($1)+"_"+string(data_value[$1])+"="+string($3);
		if(data_value[$1]=="int"){
		// varsa diye bak
			if(var_type[$1]!=data_value[$1])
			{
				data_name_int.push_back(string($1)+"_"+data_value[$1]);
				
			}
			var_type[$1]=data_value[$1];
		}
		else if(data_value[$1]=="flt"){
		// varsa diye bak
			if(var_type[$1]!=data_value[$1])
			{
			data_name_flt.push_back(string($1)+"_"+data_value[$1]);
			}
		var_type[$1]=data_value[$1];
		}
		else{
		// varsa diye bak
			if(var_type[$1]!=data_value[$1])
			{
				data_name_str.push_back(string($1)+"_"+data_value[$1]);
				
			}
			var_type[$1]=data_value[$1];
		}
		
		//cout<<last<<endl;
		
		$$=strdup(last.c_str());
		
		
		
	}
	
	
	;


operations:

	IDENTIFIER
	{
		
		string comb=string($1);
		string temp=var_type[$1];
		data_vector.push_back(string(temp));
		comb=comb+"_"+string(temp);
      		$$=strdup(comb.c_str());
	
	}
	|
	types
	{
		string comb=string($1);
		string temp=data_vector.back();
		data_vector.erase(data_vector.end());
		data_vector.push_back(string(temp));
		$$=strdup(comb.c_str());
      		
	}
	|
	operations OPERATOR operations
	{	
		string comb=string($1)+" "+string($2)+" "+string($3);
		string temp2=data_vector.back();
		data_vector.erase(data_vector.end());
		string temp1=data_vector.back();
		data_vector.erase(data_vector.end());
		
		
		if( temp1==temp2 ){
			
			data_vector.push_back(temp1);
		}
		else if(temp1=="int" && temp2=="flt"){
			 
			data_vector.push_back(temp2.c_str());
			
		}
		else if(temp1=="flt" && temp2=="int"){
			
			data_vector.push_back(temp1.c_str());

		}
		else{
			cout<<"type mismatch in line "<<++lineCount<<endl;
			exit(1);
		}
		
		$$=strdup(comb.c_str());
		
	}
	;
//----------------------------------
types_if:
	INTEGER
    	{
    		string comb=string($1);
    		data_vector_if.push_back("int");
      		$$=strdup(comb.c_str());
      
	}   
	|
	FLOAT
	{
    		string comb=string($1);
    		data_vector_if.push_back("flt");
    		$$=strdup(comb.c_str());
    	
	}
	|
	STRING
	{   
    		string comb=string($1);
    		data_vector_if.push_back("str");
    		$$=strdup(comb.c_str());
    	
	}
	;
//----------------------------------


types:
	INTEGER
	{
    	string comb=string($1);
    	data_vector.push_back("int");
      	$$=strdup(comb.c_str());
      
	}   
	|
    FLOAT
	{
    	string comb=string($1);
    	data_vector.push_back("flt");
    	$$=strdup(comb.c_str());
    	
	}
	|
	STRING
	{   
    	string comb=string($1);
    	data_vector.push_back("str");
    	$$=strdup(comb.c_str());
    	
	}
	;


tabs:
	TAB
	{tab_counter=0;
	tab_counter++;}
	|
	tabs TAB
	{tab_counter=0;
	tab_counter++;
	}
	;
	

%%







void yyerror(string s){
	cout<<"Syntax error in line  "<<lineCount<<endl;
	exit(1);
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{	
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);	
    return 0;
}

