%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Curriculum Vitae Timeline/CV - Versión en Español
% Versión: 8.5 - FINAL (corregido: foto, nombre y puesto)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\ProvidesClass{twentysecondcv-espanol}[2024/03/22 CV class en Español]
\LoadClass{article}
\NeedsTeXFormat{LaTeX2e}

%----------------------------------------------------------------------------------------
%	 PAQUETES REQUERIDOS
%----------------------------------------------------------------------------------------

\RequirePackage[sfdefault]{ClearSans}
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{tikz}
\RequirePackage{xcolor}
\RequirePackage[absolute,overlay]{textpos}
\RequirePackage{ragged2e}
\RequirePackage{etoolbox}
\RequirePackage{ifmtarg}
\RequirePackage{ifthen}
\RequirePackage{pgffor}
\RequirePackage{marvosym}
\RequirePackage{parskip}
\RequirePackage{fontawesome}
\RequirePackage{multicol}
\RequirePackage{pgf}
\RequirePackage{graphicx}
\RequirePackage{hyperref}
\RequirePackage{adjustbox}
\RequirePackage{enumitem}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\usetikzlibrary{calc}
\newsavebox\mybox
\newlength{\timelinewidth}
\setlength{\timelinewidth}{0.8cm}

%----------------------------------------------------------------------------------------
%	 COLORES
%----------------------------------------------------------------------------------------

\definecolor{white}{RGB}{255,255,255}
\definecolor{gray}{HTML}{4D4D4D}
\definecolor{sidecolor}{HTML}{E7E7E7}
\definecolor{mainblue}{HTML}{0E5484}
\definecolor{maingray}{HTML}{B9B9B9}

%----------------------------------------------------------------------------------------
%	 CONFIGURACIONES GENERALES
%----------------------------------------------------------------------------------------

\renewcommand{\textbf}[1]{{\textcolor{gray}#1}}
\pagestyle{empty}
\setlength{\parindent}{0pt}

\newcommand{\interestList}[2][ $\cdot$ ]{%
  \def\nextitem{\def\nextitem{#1}}%
  \@for \el:=#2\do{\nextitem\el}%
}

\newcommand{\makeList}[1]{%
\vspace{-0.3em}
\begin{itemize}[leftmargin=*, nosep, topsep=0pt, partopsep=0pt]
\ls{#1}
\end{itemize}
}

\def\ls#1{\lsA#1;;}
\def\lsA#1;{\ifx;#1;\else \dosomething{#1}\expandafter\lsA\fi}
\def\dosomething#1{\item #1}

%----------------------------------------------------------------------------------------
%	 DEFINICIONES DE LA BARRA LATERAL
%----------------------------------------------------------------------------------------

\setlength{\TPHorizModule}{1cm}
\setlength{\TPVertModule}{1cm}

\newlength\imagewidth
\newlength\imagescale
\pgfmathsetlength{\imagewidth}{4.2cm}
\pgfmathsetlength{\imagescale}{\imagewidth/600}

\newlength{\TotalSectionLength}
\newlength{\SectionTitleLength}

\newcommand{\profilesection}[1]{%
	\setlength\TotalSectionLength{\linewidth}%
	\settowidth{\SectionTitleLength}{\large #1 }%
	\addtolength\TotalSectionLength{-\SectionTitleLength}%
	\addtolength\TotalSectionLength{-2.22221pt}%
	\vspace{6pt}%
	{\color{black!80} \large #1 \rule[0.15\baselineskip]{\TotalSectionLength}{1pt}}%
	\vspace{2pt}%
}

% Variables booleanas
\newboolean{cv@sobremi}
\setboolean{cv@sobremi}{false}
\newboolean{cv@intereses}
\setboolean{cv@intereses}{false}
\newboolean{cv@perfil}
\setboolean{cv@perfil}{false}

% COMANDOS PARA INFORMACIÓN PERSONAL
\newcommand{\cvnombre}[1]{\def\@cvnombre{#1}}
\newcommand{\cvpuesto}[1]{\def\@cvpuesto{#1}}
\newcommand{\cvcedula}[1]{\def\@cvcedula{#1}}
\newcommand{\cvnacionalidad}[1]{\def\@cvnacionalidad{#1}}
\newcommand{\cvfecha}[1]{\def\@cvfecha{#1}}
\newcommand{\cvdireccion}[1]{\def\@cvdireccion{#1}}
\newcommand{\cvtelefono}[1]{\def\@cvtelefono{#1}}
\newcommand{\cvemail}[1]{\def\@cvemail{#1}}
\newcommand{\cvsitio}[1]{\def\@cvsitio{#1}}
\newcommand{\cvgithub}[1]{\def\@cvgithub{#1}}
\newcommand{\cvlinkedin}[1]{\def\@cvlinkedin{#1}}
\newcommand{\fotoperfil}[1]{\def\@fotoperfil{#1}}

% Valores por defecto
\def\@cvnombre{}
\def\@cvpuesto{}
\def\@cvcedula{}
\def\@cvnacionalidad{}
\def\@cvfecha{}
\def\@cvdireccion{}
\def\@cvtelefono{}
\def\@cvemail{}
\def\@cvsitio{}
\def\@cvgithub{}
\def\@cvlinkedin{}
\def\@fotoperfil{}

% Comandos para secciones de texto
\newcommand{\sobremi}[2]{\setboolean{cv@sobremi}{true}\renewcommand{\sobremi}{%
\begin{minipage}{\linewidth}
\profilesection{#1}
\begin{justify}%
\small #2%
\end{justify}%
\end{minipage}
\vspace{8pt}
}}

\newcommand{\intereses}[2]{\setboolean{cv@intereses}{true}\renewcommand{\intereses}{%
\begin{minipage}{\linewidth}
\profilesection{#1}
\begin{justify}%
\small \interestList{#2}%
\end{justify}%
\end{minipage}
\vspace{8pt}
}}

\newcommand{\perfil}[2]{\setboolean{cv@perfil}{true}\renewcommand{\perfil}{%
\begin{minipage}{\linewidth}
\profilesection{#1}
\begin{justify}%
\small #2%
\end{justify}%
\end{minipage}
\vspace{8pt}
}}

\newcommand*\icon[1]{\tikz[baseline=(char.base)]{\node[shape=circle,draw,inner sep=0.3pt, fill=mainblue,mainblue,text=white, font=\tiny] (char) {#1};}}

\newcommand\habilidades[1]{ 
	\renewcommand{\habilidades}{
		\begin{minipage}{\linewidth}
		\profilesection{Habilidades}
		\begin{tikzpicture}[scale=0.85]
			\foreach [count=\i] \x/\y in {#1}{
				\draw[fill=maingray,maingray] (0,-\i) rectangle (4.8,-\i+0.28);
				\draw[fill=white,mainblue](0,-\i) rectangle (0.96*\y,-\i+0.28);
				\node [above right, font=\small] at (0,-\i+0.28) {\x};
				\foreach \z in {0,1,2,...,10}
                {
				    \coordinate (A\z) at ($(0,-\i)+(0.96*\z*0.5cm,0)$) {};
				    \ifodd\z
                        \draw[white] ($(A\z)$) -- ($(A\z)+(0,1.8pt)$);
                    \else
                        \draw[white] ($(A\z)$) -- ($(A\z)+(0,3.6pt)$);
                    \fi
                }
			}
		\end{tikzpicture}
		\vspace{4pt}
		{\tiny \hfill Escala: 0 (Básico) a 5 (Experto) \hfill \phantom{}}
		\vspace{2pt}
		\end{minipage}
		\vspace{8pt}
	}
}

\def\timeline#1#2#3#4#5{
    \begin{minipage}[c]{\timelinewidth}
        \centering
        \begin{tikzpicture}[scale=0.8, every node/.style={scale=0.8}]
            \node [below, font=\tiny] at (0,-0.1) {#4};
            \path [bottom color=#2,top color=#3] (-0.15,0) rectangle (0.15,#1-1) ;
            \node [above, font=\tiny] at (0,#1-0.9) {#5};
        \end{tikzpicture}
    \end{minipage}
}

%----------------------------------------------------------------------------------------
%	 CONSTRUCCIÓN DE LA BARRA LATERAL - VERSIÓN CORREGIDA
%----------------------------------------------------------------------------------------

\newcommand{\crearperfil}{
	\begin{tikzpicture}[remember picture,overlay]
   		\node [rectangle, fill=sidecolor, anchor=north, minimum width=9cm, minimum height=\paperheight+1cm] (box) at (-5cm,0.5cm){};
	\end{tikzpicture}

	\begin{textblock}{6}(0.5, 0.1)
			
		% Foto de perfil - CORREGIDO
		\ifx\@fotoperfil\empty
			% No hay foto, mostrar círculo vacío con icono
			\begin{center}
				\begin{minipage}{0.9\linewidth}
					\begin{center}
						\begin{tikzpicture}
							\draw[fill=white, draw=mainblue, line width=2pt] (0,0) circle (1.8cm);
							\node at (0,0) {\fontsize{50}{60}\selectfont\color{mainblue}\faUser};
						\end{tikzpicture}
					\end{center}
				\end{minipage}
			\end{center}
		\else
			\begin{center}
				\begin{minipage}{0.9\linewidth}
					\begin{center}
						\begin{tikzpicture}[x=\imagescale,y=-\imagescale]
							\clip (600/2, 567/2) circle (567/2);
							\node[anchor=north west, inner sep=0pt, outer sep=0pt] at (0,0) {\includegraphics[width=\imagewidth]{\@fotoperfil}};
						\end{tikzpicture}
					\end{center}
				\end{minipage}
			\end{center}
		\fi
		\vspace{0.3cm}

		% NOMBRE - CORREGIDO
		\begin{center}
			\begin{minipage}{0.95\linewidth}
				\begin{center}
					{\Huge\bfseries\color{mainblue}\@cvnombre\par}
				\end{center}
			\end{minipage}
		\end{center}
		
		\vspace{0.2cm}
		
		% PUESTO - CORREGIDO
		\begin{center}
			\begin{minipage}{0.95\linewidth}
				\begin{center}
					{\Large\color{black!80}\@cvpuesto\par}
				\end{center}
			\end{minipage}
		\end{center}
		
		\vspace{0.4cm}

		% INFORMACIÓN DE CONTACTO
		\begin{minipage}{\linewidth}
			\renewcommand{\arraystretch}{1.2}
			\begin{tabular}{p{0.5cm} @{\hskip 0.3cm}p{4.7cm}}
				\ifx\@cvcedula\empty\else\textsc{\tiny\icon{\faFolderOpen}} & \footnotesize\@cvcedula\\\fi
				\ifx\@cvnacionalidad\empty\else\textsc{\tiny\icon{\faFlag}} & \footnotesize\@cvnacionalidad\\\fi
				\ifx\@cvfecha\empty\else\textsc{\tiny\icon{\faCalendar}} & \footnotesize\@cvfecha\\\fi
				\ifx\@cvdireccion\empty\else\textsc{\tiny\icon{\faGlobe}} & \footnotesize\@cvdireccion\\\fi
				\ifx\@cvtelefono\empty\else\textsc{\tiny\icon{\faPhone}} & \footnotesize\@cvtelefono\\\fi
				\ifx\@cvsitio\empty\else\textsc{\tiny\icon{\faUser}} & \footnotesize\href{\@cvsitio}{\@cvsitio}\\\fi
				\ifx\@cvemail\empty\else\textsc{\tiny\icon{\faAt}} & \footnotesize\href{mailto:\@cvemail}{\@cvemail}\\\fi
				\ifx\@cvgithub\empty\else\textsc{\tiny\icon{\faGithub}} & \footnotesize\href{https://www.github.com/\@cvgithub}{\@cvgithub}\\\fi
				\ifx\@cvlinkedin\empty\else\textsc{\tiny\icon{\faLinkedin}} & \footnotesize\href{https://www.linkedin.com/in/\@cvlinkedin}{\@cvlinkedin}\fi
			\end{tabular}
		\end{minipage}
		
		\vspace{0.4cm}

		% Secciones de texto
		\ifthenelse{\boolean{cv@perfil}}{
	        \emergencystretch=3em
	        \perfil
	    }{}
	    
	    \ifthenelse{\boolean{cv@sobremi}}{
	        \emergencystretch=3em
	        \sobremi
	    }{}
	    
	    \ifthenelse{\boolean{cv@intereses}}{
	        \emergencystretch=3em
	        \intereses
	    }{}
		
		% Habilidades
		\habilidades
			
	\end{textblock}
}

%----------------------------------------------------------------------------------------
%	 TÍTULOS DE SECCIÓN
%----------------------------------------------------------------------------------------

\newcommand*\recuadro[2]{%
	\tikz[baseline=(char.base)]\node[anchor=north west, draw,rectangle, rounded corners, inner sep=1.2pt, minimum size=4.5mm, text height=3mm, fill=#2,#2,text=white](char){#1};%
}

\newcounter{contadorColor}
\newcommand{\colorseccion}[1]{%
	{%
		\recuadro{#1}{
			\ifcase\value{contadorColor}%
			maingray\or%
			mainblue\or%
			maingray\or%
			mainblue\or%
			maingray\or%
			mainblue\or%
			maingray\or%
			mainblue\or%
 			maingray\or%
			mainblue\else%
			maingray\fi%
		}%
	}%
	\stepcounter{contadorColor}%
}

\renewcommand{\section}[1]{
	{%
		\color{gray}%
		\large\colorseccion{#1}%
	}
	\vspace{0.1cm}
}

\renewcommand{\subsection}[1]{
	\par\vspace{.3\parskip}{%
		\large\color{gray} #1%
	}
	\par\vspace{.15\parskip}%
}

%----------------------------------------------------------------------------------------
%	 ENTORNOS DE LISTAS
%----------------------------------------------------------------------------------------

\setlength{\tabcolsep}{0pt}

\newenvironment{veinte}{%
    \par\vspace{0.2cm}
    \noindent
    \begin{list}{}{%
        \setlength{\leftmargin}{0pt}
        \setlength{\rightmargin}{0pt}
        \setlength{\labelwidth}{0pt}
        \setlength{\labelsep}{0pt}
        \setlength{\itemsep}{8pt}
        \setlength{\topsep}{0pt}
    }
    \item[]
}{%
    \end{list}
}

\newcommand{\veinteitemtiempo}[7]{%
    \noindent
    \begin{minipage}[t]{\timelinewidth}
        \vspace{0.1cm}
        \centering
        \begin{tikzpicture}[scale=0.8, every node/.style={scale=0.8}]
            \node [below, font=\tiny] at (0,-0.1) {#3};
            \path [bottom color=#1,top color=#2] (-0.15,0) rectangle (0.15,1.2) ;
            \node [above, font=\tiny] at (0,1.1) {#4};
        \end{tikzpicture}
    \end{minipage}%
    \hspace{0.5cm}%
    \begin{minipage}[t]{\dimexpr\linewidth-\timelinewidth-0.8cm\relax}
        \textbf{#5} \hfill {\footnotesize #6}\par
        \vspace{0.1cm}
        \small #7\par
    \end{minipage}
    
    \vspace{0.3cm}
}

\newcommand{\veinteitem}[4]{%
    \noindent
    \begin{minipage}[t]{\timelinewidth}
        \vspace{0.1cm}
        \centering
        {\footnotesize #1}
    \end{minipage}%
    \hspace{0.5cm}%
    \begin{minipage}[t]{\dimexpr\linewidth-\timelinewidth-0.8cm\relax}
        \textbf{#2} \hfill {\footnotesize #3}\par
        \vspace{0.1cm}
        \small #4\par
    \end{minipage}
    
    \vspace{0.3cm}
}

%----------------------------------------------------------------------------------------
%	 MÁRGENES Y ENLACES
%----------------------------------------------------------------------------------------

\RequirePackage[left=7.0cm,top=0.05cm,right=1cm,bottom=0.1cm,nohead,nofoot]{geometry}

\hypersetup{%
  colorlinks=true,%
  linkcolor=black,%
  anchorcolor=black,%
  citecolor=black,%
  urlcolor=black,%
  bookmarksnumbered=false%
}

\setlength{\parskip}{0.2\baselineskip}
\setlist{nosep, leftmargin=*, topsep=0pt, partopsep=0pt}