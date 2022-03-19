#include <stdio.h>
#include <stdlib.h>

struct node{
	int vertice;
	struct node* next;
};


//funcao extremamente importante para procurar o ultimo node inserido
//sem ela nao eh possivel andar pelos nos encadeados
struct node* procura(struct node *position){
	while(position->next != NULL){
		position = position->next;
	}
	return position;
}


//funcao que incializa nossos vertices
void inicializa(struct node* V, int tam){
	for(int i =0;i < tam;i++){
		V[i].vertice = 0;
		V[i].next = NULL;
		
	}
}

/* funcao que aloca um espaco na memoria
 para um novo no */
struct node* crianode(int vertice){
	struct node* novo = (struct node*) malloc(sizeof(struct node));
	novo->vertice = vertice;
	novo->next = NULL;
	return novo;
}


void addVertice(struct node* V,int v1, int v2,int orientacaoArestas){
	
	
	
	
	if(orientacaoArestas == 0){


		// se eu nao colocar o v1-1 o grafo vai ficar
		// todo deslocado "pra frente".Isso conserta os vertices

		/*Se estiver vazio basta inserir normalmente */

		if(V[v1 - 1].vertice == 0){
			
			V[v1 - 1].vertice = v2;
		}
		//Se nao estiver vazio, ou seja, já tem algum no
		/*Nessa funcao colocamos em um ponteiro	
		(temp) o ultimo no colocado,e a partir disso alocamos espaco pra um outro no

		*/
		else {
			struct node * temp = procura(&V[v1 - 1]);
			//printf("%p",temp);
			struct node* novoNo = crianode(v2);
			temp->next = novoNo;
			
		}

		//se vertice1 eh igual a vertice2 termina a execucao dessa funcao
		//exemplo 4
		if(v1 == v2)
			return;

		/*Para grafos nao direcionados
		  se eu ligar 1 ao 2 o 2 precisa ser ligado ao 1. ou seja
		1->2
		2->1
		 */
		
		if(V[v2- 1].vertice == 0){
			
			V[v2- 1].vertice = v1;
		}
		else{
			struct node* temp = procura(&V[v2 - 1]);

			struct node* novoNo = crianode(v1);
			temp->next = novoNo;
		}
	} else if(orientacaoArestas == 1){
		//Para grafos direcionados
		//se eu ligar por ex 1 e 2. So vou ter a ligacao 1 liga 2. Nao vou ter a 2 liga 1.
		
		if(v1 == v2)
			return;

		if(V[v1 - 1].vertice == 0){
			
			V[v1 - 1].vertice = v2;
		}
		else {
			struct node * temp = procura(&V[v1 - 1]);
			struct node* novoNo = crianode(v2);
			temp->next = novoNo;
			
		}
		

	}
		
}



void printG(struct node* V,int tam){
		
	struct node *p;
	for(int i =0 ;i < tam;i++){

		//pego o endereço onde está cada posicao de V
		p = &V[i];
		printf("%d: ",i+ 1);

		if(p->vertice != 0){
			printf("%d ",p->vertice);

			//preciso percorrer o encadeamento na lista e vou printando
			while(p->next != NULL){
				p = p->next;
				printf(" %d",p->vertice);
			}
		
		}
		printf("\n");
	}
}


//estrutura dessa funcao eh bem parecida com a Verifyloops














//tam EH A QUANTIDADE DE VERTICES
//NA MAIN EH Vertices.
void printGrau(int *grau,int tam){
	int max,min;
	
	for(int i =0;i < tam;i++){
		
		
		if(i == 0){
			max = grau[i];
			min = grau[i];
			
		} else {
			if(grau[i] < min)
				min = grau[i];
			if(grau[i] > max)
				max = grau[i];
				
		}
	}
	
	
	
	for(int i =0;i < tam;i++){
		printf("Vértice %d tem grau %d\n",i + 1,grau[i]);
		
	}
	printf("\n");
	printf("Grau maximo: %d\n",max);
	printf("Grau minimo: %d\n",min);
	printf("\n");

}




int main(){
	//tam eh a qdade de vertices/
	//int tam = 5;
	//struct node *v = (struct node*) malloc (sizeof (struct node) * tam);


	int Vertices,Arestas,Direcao;
	scanf("%d %d %d",&Vertices,&Arestas,&Direcao);

	if(Direcao == 0){

		//declaro e inicializo o vetor de grau com zero
		int *grau = (int *) malloc(sizeof(int)*Vertices);

		for(int i =0;i < Vertices;i++)
			grau[i] = 0;


		struct node* v = (struct node*) malloc(sizeof(struct node)* Vertices);
		
		//inicializa o vetor com o tamanho adeuqado e com o numero de vertice ja indicado acima
		inicializa(v, Vertices);

		int Vertice1,Vertice2;

		for(int i =0 ;i < Arestas;i++){
			scanf("%d %d",&Vertice1,&Vertice2);
			
			//esse [Vertice1 -1] eh o mesmo caso
			//do addVertice. Se nao tivesse esse menos 1
			//o grafo estaria literalmente deslocado
			//nesse caso me daria os nos com o grau do vertice seguinte
			grau[Vertice1 - 1]++;
			grau[Vertice2- 1]++;

			addVertice(v,Vertice1,Vertice2,0);
		}
		printG(v,Vertices);
		printf("\n");
		
		printGrau(grau,Vertices);

		
		
	} else if(Direcao == 1){
		struct node* vdirecionado = (struct node*) malloc(sizeof(struct node)* Vertices);

		inicializa(vdirecionado, Vertices);

		int V1,V2;

		int *graudir = (int *) malloc(sizeof(int)*Vertices);

		for(int i =0;i < Vertices;i++)
			graudir[i] = 0;

		for(int i =0;i < Arestas;i++){
			scanf("%d %d",&V1,&V2);
			graudir[V1 - 1]++;
			graudir[V2- 1]++;

			addVertice(vdirecionado,V1,V2,1);
		}
		printG(vdirecionado,Vertices);
	}

	

	return 0;
}