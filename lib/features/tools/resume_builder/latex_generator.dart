import 'resume_builder_data.dart';

/// User ka ResumeData -> 4 alag templates ka LaTeX code.
class LatexGenerator {
  static String _esc(String text) {
    return text
        .replaceAll('\\', r'\textbackslash{}')
        .replaceAll('&', r'\&')
        .replaceAll('%', r'\%')
        .replaceAll(r'$', r'\$')
        .replaceAll('#', r'\#')
        .replaceAll('_', r'\_')
        .replaceAll('{', r'\{')
        .replaceAll('}', r'\}')
        .replaceAll('~', r'\textasciitilde{}')
        .replaceAll('^', r'\textasciicircum{}');
  }

  static String generate(ResumeData data, String templateId) {
    switch (templateId) {
      case 'classic':
        return _template2(data);
      case 'modern':
        return _template3(data);
      case 'lato':
        return _template4(data);
      case 'jake':
      default:
        return _template1(data);
    }
  }

  static void _bullets(StringBuffer b, String desc) {
    if (desc.trim().isEmpty) return;
    b.writeln(r'\resumeItemListStart');
    for (final line in desc.split('\n')) {
      if (line.trim().isNotEmpty) {
        b.writeln('\\resumeItem{${_esc(line.trim())}}');
      }
    }
    b.writeln(r'\resumeItemListEnd');
  }

  // ===== TEMPLATE 1 — Jake's =====
  static String _template1(ResumeData d) {
    final b = StringBuffer();
    b.writeln(_preamble1);
    b.writeln(r'\begin{document}');
    b.writeln(r'\begin{center}');
    b.writeln('    \\textbf{\\Huge \\scshape ${_esc(d.fullName.isEmpty ? "Your Name" : d.fullName)}} \\\\ \\vspace{3pt}');
    final c = <String>[];
    if (d.phone.isNotEmpty) c.add('\\small ${_esc(d.phone)}');
    if (d.email.isNotEmpty) c.add('\\href{mailto:${_esc(d.email)}}{\\underline{${_esc(d.email)}}}');
    if (d.linkedIn.isNotEmpty) c.add('\\underline{${_esc(d.linkedIn)}}');
    if (d.github.isNotEmpty) c.add('\\underline{${_esc(d.github)}}');
    if (d.location.isNotEmpty) c.add(_esc(d.location));
    if (c.isNotEmpty) b.writeln('    \\small ${c.join(r' $|$ ')}');
    b.writeln(r'\end{center}');
    if (d.summary.isNotEmpty) {
      b.writeln(r'\section{Summary}');
      b.writeln(r'\resumeSubHeadingListStart');
      b.writeln('\\resumeItem{${_esc(d.summary)}}');
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.experiences.isNotEmpty) {
      b.writeln(r'\section{Experience}');
      b.writeln(r'\resumeSubHeadingListStart');
      for (final e in d.experiences) {
        b.writeln('\\resumeSubheading{${_esc(e.jobTitle)}}{${_esc(e.duration)}}{${_esc(e.company)}}{${_esc(e.location)}}');
        _bullets(b, e.description);
      }
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.projects.isNotEmpty) {
      b.writeln(r'\section{Projects}');
      b.writeln(r'\resumeSubHeadingListStart');
      for (final p in d.projects) {
        final head = p.techStack.isNotEmpty
            ? '\\textbf{${_esc(p.name)}} \$|\$ \\emph{${_esc(p.techStack)}}'
            : '\\textbf{${_esc(p.name)}}';
        b.writeln('\\resumeProjectHeading{$head}{${_esc(p.year)}}');
        _bullets(b, p.description);
      }
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.educations.isNotEmpty) {
      b.writeln(r'\section{Education}');
      b.writeln(r'\resumeSubHeadingListStart');
      for (final e in d.educations) {
        b.writeln('\\resumeSubheading{${_esc(e.institution)}}{${_esc(e.year)}}{${_esc(e.degree)}}{${_esc(e.location)}}');
        if (e.coursework.isNotEmpty) {
          b.writeln(r'\resumeItemListStart');
          b.writeln('\\resumeItem{\\textbf{Coursework}: ${_esc(e.coursework)}}');
          b.writeln(r'\resumeItemListEnd');
        }
      }
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.skills.isNotEmpty) {
      b.writeln(r'\section{Skills}');
      b.writeln(r' \begin{itemize}[leftmargin=0.15in, label={}]');
      b.writeln('    \\small{\\item{\\textbf{Skills}{: ${_esc(d.skills.join(', '))}}}}');
      b.writeln(r' \end{itemize}');
    }
    if (d.achievements.isNotEmpty) {
      b.writeln(r'\section{Achievements}');
      b.writeln(r'\resumeSubHeadingListStart');
      for (final a in d.achievements) {
        if (a.trim().isNotEmpty) b.writeln('\\resumeItem{${_esc(a.trim())}}');
      }
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    b.writeln(r'\end{document}');
    return b.toString();
  }

  // ===== TEMPLATE 2 — Jitin autoCV =====
  static String _template2(ResumeData d) {
    final b = StringBuffer();
    b.writeln(_preamble2);
    b.writeln(r'\begin{document}');
    b.writeln(r'\pagestyle{empty}');
    b.writeln(r'\begin{tabularx}{\linewidth}{@{} C @{}}');
    b.writeln('\\Huge{${_esc(d.fullName.isEmpty ? "Your Name" : d.fullName)}} \\\\[7.5pt]');
    final parts = <String>[];
    if (d.email.isNotEmpty) parts.add('\\href{mailto:${_esc(d.email)}}{\\raisebox{-0.05\\height}\\faEnvelope\\ ${_esc(d.email)}}');
    if (d.linkedIn.isNotEmpty) parts.add('\\raisebox{-0.05\\height}\\faLinkedin\\ ${_esc(d.linkedIn)}');
    if (d.github.isNotEmpty) parts.add('\\raisebox{-0.05\\height}\\faGithub\\ ${_esc(d.github)}');
    if (d.phone.isNotEmpty) parts.add('\\raisebox{-0.05\\height}\\faMobile\\ ${_esc(d.phone)}');
    if (d.location.isNotEmpty) parts.add('\\raisebox{-0.05\\height}\\faMapMarker\\ ${_esc(d.location)}');
    b.writeln('${parts.join(r' \ $|$ \ ')} \\\\');
    b.writeln(r'\end{tabularx}');
    if (d.summary.isNotEmpty) {
      b.writeln(r'\section{Summary}');
      b.writeln(_esc(d.summary));
    }
    if (d.experiences.isNotEmpty) {
      b.writeln(r'\section{Work Experience}');
      for (final e in d.experiences) {
        final title = e.company.isNotEmpty ? '${_esc(e.jobTitle)}, ${_esc(e.company)}' : _esc(e.jobTitle);
        b.writeln('\\begin{joblong}{$title}{${_esc(e.duration)}}');
        for (final line in e.description.split('\n')) {
          if (line.trim().isNotEmpty) b.writeln('\\item ${_esc(line.trim())}');
        }
        b.writeln(r'\end{joblong}');
      }
    }
    if (d.projects.isNotEmpty) {
      b.writeln(r'\section{Projects}');
      for (final p in d.projects) {
        b.writeln(r'\begin{tabularx}{\linewidth}{ @{}l r@{} }');
        b.writeln('\\textbf{${_esc(p.name)}} & \\hfill ${_esc(p.techStack)} \\\\[3.75pt]');
        b.writeln('\\multicolumn{2}{@{}X@{}}{${_esc(p.description)}}  \\\\');
        b.writeln(r'\end{tabularx}');
        b.writeln(r'\vspace{4pt}');
      }
    }
    if (d.educations.isNotEmpty) {
      b.writeln(r'\section{Education}');
      b.writeln(r'\begin{tabularx}{\linewidth}{@{}l X@{}}');
      for (final e in d.educations) {
        b.writeln('${_esc(e.year)} & ${_esc(e.degree)} at \\textbf{${_esc(e.institution)}} \\\\');
      }
      b.writeln(r'\end{tabularx}');
    }
    if (d.skills.isNotEmpty) {
      b.writeln(r'\section{Skills}');
      b.writeln(r'\begin{tabularx}{\linewidth}{@{}l X@{}}');
      b.writeln('Skills & \\normalsize{${_esc(d.skills.join(', '))}}\\\\');
      b.writeln(r'\end{tabularx}');
    }
    if (d.achievements.isNotEmpty) {
      b.writeln(r'\section{Achievements}');
      b.writeln(r'\begin{itemize}[leftmargin=1em, itemsep=3pt, label=--]');
      for (final a in d.achievements) {
        if (a.trim().isNotEmpty) b.writeln('\\item ${_esc(a.trim())}');
      }
      b.writeln(r'\end{itemize}');
    }
    b.writeln(r'\end{document}');
    return b.toString();
  }

  // ===== TEMPLATE 3 — Anubhav =====
  static String _template3(ResumeData d) {
    final b = StringBuffer();
    b.writeln(_preamble3);
    b.writeln(r'\begin{document}');
    b.writeln(r'\begin{tabular*}{\textwidth}{l@{\extracolsep{\fill}}r}');
    b.writeln('  \\textbf{{\\LARGE ${_esc(d.fullName.isEmpty ? "Your Name" : d.fullName)}}} & ${d.email.isNotEmpty ? "Email: \\href{mailto:${_esc(d.email)}}{${_esc(d.email)}}" : ""}\\\\');
    if (d.linkedIn.isNotEmpty || d.phone.isNotEmpty) {
      b.writeln('  ${d.linkedIn.isNotEmpty ? "LinkedIn: ${_esc(d.linkedIn)}" : ""} & ${d.phone.isNotEmpty ? "Mobile:~~~${_esc(d.phone)}" : ""} \\\\');
    }
    if (d.github.isNotEmpty || d.location.isNotEmpty) {
      b.writeln('  ${d.github.isNotEmpty ? "Github: ${_esc(d.github)}" : ""} & ${d.location.isNotEmpty ? "Location: ${_esc(d.location)}" : ""} \\\\');
    }
    b.writeln(r'\end{tabular*}');
    if (d.summary.isNotEmpty) {
      b.writeln(r'\section{~~Summary}');
      b.writeln(r'\resumeSubHeadingListStart');
      b.writeln('\\item\\small{${_esc(d.summary)}}');
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.experiences.isNotEmpty) {
      b.writeln(r'\section{~~Experience}');
      b.writeln(r'  \resumeSubHeadingListStart');
      for (final e in d.experiences) {
        b.writeln('    \\resumeSubheading{${_esc(e.company)}}{${_esc(e.location)}}{${_esc(e.jobTitle)}}{${_esc(e.duration)}}');
        if (e.description.trim().isNotEmpty) {
          b.writeln(r'    \resumeItemListStart');
          for (final line in e.description.split('\n')) {
            if (line.trim().isNotEmpty) b.writeln('        \\item\\small{${_esc(line.trim())}}');
          }
          b.writeln(r'      \resumeItemListEnd');
        }
      }
      b.writeln(r'  \resumeSubHeadingListEnd');
    }
    if (d.projects.isNotEmpty) {
      b.writeln(r'\section{~~Projects}');
      b.writeln(r'\resumeSubHeadingListStart');
      for (final p in d.projects) {
        final head = p.techStack.isNotEmpty ? '${_esc(p.name)} (${_esc(p.techStack)})' : _esc(p.name);
        b.writeln('\\resumeSubItem{$head}{${_esc(p.description)}}');
        b.writeln(r'\vspace{2pt}');
      }
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.educations.isNotEmpty) {
      b.writeln(r'\section{~~Education}');
      b.writeln(r'  \resumeSubHeadingListStart');
      for (final e in d.educations) {
        b.writeln('    \\resumeSubheading{${_esc(e.institution)}}{${_esc(e.location)}}{${_esc(e.degree)}}{${_esc(e.year)}}');
      }
      b.writeln(r'    \resumeSubHeadingListEnd');
    }
    if (d.skills.isNotEmpty) {
      b.writeln(r'\section{~~Skills}');
      b.writeln(r'	\resumeSubHeadingListStart');
      b.writeln('	\\item\\small{\\textbf{Skills}{: ${_esc(d.skills.join(', '))}}}');
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.achievements.isNotEmpty) {
      b.writeln(r'\section{~~Achievements}');
      b.writeln(r'\begin{description}[font=$\bullet$, leftmargin=1em, itemsep=2pt]');
      for (final a in d.achievements) {
        if (a.trim().isNotEmpty) b.writeln('\\item {${_esc(a.trim())}}');
      }
      b.writeln(r'\end{description}');
    }
    b.writeln(r'\end{document}');
    return b.toString();
  }

  // ===== TEMPLATE 4 — Audric (Lato) =====
  static String _template4(ResumeData d) {
    final b = StringBuffer();
    b.writeln(_preamble4);
    b.writeln(r'\begin{document}');
    b.writeln(r'\begin{center}');
    b.writeln('    {\\Huge ${_esc(d.fullName.isEmpty ? "Your Name" : d.fullName)}} \\\\ \\vspace{5pt}');
    final parts = <String>[];
    if (d.phone.isNotEmpty) parts.add('\\faPhone\\ ${_esc(d.phone)}');
    if (d.email.isNotEmpty) parts.add('\\faEnvelope\\ \\href{mailto:${_esc(d.email)}}{${_esc(d.email)}}');
    if (d.linkedIn.isNotEmpty) parts.add('\\faLinkedin\\ ${_esc(d.linkedIn)}');
    if (d.github.isNotEmpty) parts.add('\\faGithub\\ ${_esc(d.github)}');
    if (d.location.isNotEmpty) parts.add('\\faMapMarker\\ ${_esc(d.location)}');
    b.writeln('    \\footnotesize ${parts.join(' ~~ ')}');
    b.writeln(r'\end{center}');
    b.writeln(r'\vspace{2pt}');
    if (d.summary.isNotEmpty) {
      b.writeln(r'\section{Summary}');
      b.writeln('\\small{${_esc(d.summary)}}');
      b.writeln(r'\vspace{4pt}');
    }
    if (d.experiences.isNotEmpty) {
      b.writeln(r'\section{Experience}');
      b.writeln(r'\resumeSubHeadingListStart');
      for (final e in d.experiences) {
        b.writeln('\\resumeSubheading{${_esc(e.jobTitle)}}{${_esc(e.duration)}}{${_esc(e.company)}}{${_esc(e.location)}}');
        _bullets(b, e.description);
      }
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.projects.isNotEmpty) {
      b.writeln(r'\section{Projects}');
      b.writeln(r'\resumeSubHeadingListStart');
      for (final p in d.projects) {
        final head = p.techStack.isNotEmpty
            ? '\\textbf{${_esc(p.name)}} \$|\$ \\emph{${_esc(p.techStack)}}'
            : '\\textbf{${_esc(p.name)}}';
        b.writeln('\\resumeProjectHeading{$head}{${_esc(p.year)}}');
        _bullets(b, p.description);
      }
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.educations.isNotEmpty) {
      b.writeln(r'\section{Education}');
      b.writeln(r'\resumeSubHeadingListStart');
      for (final e in d.educations) {
        b.writeln('\\resumeSubheading{${_esc(e.institution)}}{${_esc(e.year)}}{${_esc(e.degree)}}{${_esc(e.location)}}');
      }
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.skills.isNotEmpty) {
      b.writeln(r'\section{Skills}');
      b.writeln(r'\resumeSubHeadingListStart');
      b.writeln('\\small{\\item{\\textbf{Skills}{: ${_esc(d.skills.join(', '))}}}}');
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    if (d.achievements.isNotEmpty) {
      b.writeln(r'\section{Achievements}');
      b.writeln(r'\resumeSubHeadingListStart');
      for (final a in d.achievements) {
        if (a.trim().isNotEmpty) b.writeln('\\resumeItem{${_esc(a.trim())}}');
      }
      b.writeln(r'\resumeSubHeadingListEnd');
    }
    b.writeln(r'\end{document}');
    return b.toString();
  }

  static const String _preamble1 = r'''
\documentclass[letterpaper,11pt]{article}
\usepackage{latexsym}
\usepackage[empty]{fullpage}
\usepackage{titlesec}
\usepackage{marvosym}
\usepackage[usenames,dvipsnames]{color}
\usepackage{verbatim}
\usepackage{enumitem}
\usepackage[hidelinks]{hyperref}
\usepackage{fancyhdr}
\usepackage[english]{babel}
\usepackage{tabularx}
\input{glyphtounicode}
\pagestyle{fancy}
\fancyhf{}
\fancyfoot{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\addtolength{\oddsidemargin}{-0.5in}
\addtolength{\evensidemargin}{-0.5in}
\addtolength{\textwidth}{1in}
\addtolength{\topmargin}{-.5in}
\addtolength{\textheight}{1.0in}
\urlstyle{same}
\raggedbottom
\raggedright
\setlength{\tabcolsep}{0in}
\titleformat{\section}{\vspace{-4pt}\scshape\raggedright\large}{}{0em}{}[\color{black}\titlerule \vspace{-5pt}]
\pdfgentounicode=1
\newcommand{\resumeItem}[1]{\item\small{{#1 \vspace{-2pt}}}}
\newcommand{\resumeSubheading}[4]{\vspace{-2pt}\item\begin{tabular*}{0.97\textwidth}[t]{l@{\extracolsep{\fill}}r}\textbf{#1} & #2 \\\textit{\small#3} & \textit{\small #4} \\\end{tabular*}\vspace{-7pt}}
\newcommand{\resumeProjectHeading}[2]{\item\begin{tabular*}{0.97\textwidth}{l@{\extracolsep{\fill}}r}\small#1 & #2 \\\end{tabular*}\vspace{-7pt}}
\renewcommand\labelitemii{$\vcenter{\hbox{\tiny$\bullet$}}$}
\newcommand{\resumeSubHeadingListStart}{\begin{itemize}[leftmargin=0.15in, label={}]}
\newcommand{\resumeSubHeadingListEnd}{\end{itemize}}
\newcommand{\resumeItemListStart}{\begin{itemize}}
\newcommand{\resumeItemListEnd}{\end{itemize}\vspace{-5pt}}
''';

  static const String _preamble2 = r'''
\documentclass[a4paper,11pt]{article}
\usepackage{url}
\usepackage{parskip}
\RequirePackage{color}
\RequirePackage{graphicx}
\usepackage[usenames,dvipsnames]{xcolor}
\usepackage[scale=0.9]{geometry}
\usepackage{tabularx}
\usepackage{enumitem}
\newcolumntype{C}{>{\centering\arraybackslash}X}
\usepackage{supertabular}
\usepackage{multicol}
\usepackage{titlesec}
\titleformat{\section}{\Large\scshape\raggedright}{}{0em}{}[\titlerule]
\titlespacing{\section}{0pt}{10pt}{10pt}
\usepackage[unicode, draft=false]{hyperref}
\definecolor{linkcolour}{rgb}{0,0.2,0.6}
\hypersetup{colorlinks,breaklinks,urlcolor=linkcolour,linkcolor=linkcolour}
\usepackage{fontawesome5}
\newenvironment{joblong}[2]{\begin{tabularx}{\linewidth}{@{}l X r@{}}\textbf{#1} & \hfill &  #2 \\[3.75pt]\end{tabularx}\begin{minipage}[t]{\linewidth}\begin{itemize}[nosep,after=\strut, leftmargin=1em, itemsep=3pt,label=--]}{\end{itemize}\end{minipage}}
''';

  static const String _preamble3 = r'''
\documentclass[a4paper,11pt]{article}
\usepackage{latexsym}
\usepackage[empty]{fullpage}
\usepackage{titlesec}
\usepackage{marvosym}
\usepackage[usenames,dvipsnames]{color}
\usepackage{verbatim}
\usepackage{enumitem}
\usepackage[pdftex]{hyperref}
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}
\fancyfoot{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\addtolength{\oddsidemargin}{-0.530in}
\addtolength{\evensidemargin}{-0.375in}
\addtolength{\textwidth}{1in}
\addtolength{\topmargin}{-.45in}
\addtolength{\textheight}{1in}
\urlstyle{rm}
\raggedbottom
\raggedright
\setlength{\tabcolsep}{0in}
\titleformat{\section}{\vspace{-8pt}\scshape\raggedright\large}{}{0em}{}[\color{black}\titlerule \vspace{-4pt}]
\newcommand{\resumeItem}[2]{\item\small{\textbf{#1}{: #2 \vspace{-2pt}}}}
\newcommand{\resumeSubheading}[4]{\vspace{1pt}\item\begin{tabular*}{0.97\textwidth}{l@{\extracolsep{\fill}}r}\textbf{#1} & #2 \\\textit{#3} & \textit{#4} \\\end{tabular*}\vspace{-3pt}}
\newcommand{\resumeSubItem}[2]{\resumeItem{#1}{#2}\vspace{-3pt}}
\renewcommand{\labelitemii}{$\circ$}
\newcommand{\resumeSubHeadingListStart}{\begin{itemize}[leftmargin=*]}
\newcommand{\resumeSubHeadingListEnd}{\end{itemize}}
\newcommand{\resumeItemListStart}{\begin{itemize}}
\newcommand{\resumeItemListEnd}{\end{itemize}\vspace{-4pt}}
''';

  static const String _preamble4 = r'''
\documentclass[letterpaper,11pt]{article}
\usepackage{fontawesome5}
\usepackage{latexsym}
\usepackage[empty]{fullpage}
\usepackage{titlesec}
\usepackage{marvosym}
\usepackage[usenames,dvipsnames]{color}
\usepackage{verbatim}
\usepackage{enumitem}
\usepackage[hidelinks]{hyperref}
\usepackage{fancyhdr}
\usepackage[english]{babel}
\usepackage{tabularx}
\input{glyphtounicode}
\usepackage[default]{lato}
\pagestyle{fancy}
\fancyhf{}
\fancyfoot{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\addtolength{\oddsidemargin}{-0.5in}
\addtolength{\evensidemargin}{-0.5in}
\addtolength{\textwidth}{1in}
\addtolength{\topmargin}{-.7in}
\addtolength{\textheight}{1.3in}
\urlstyle{same}
\raggedbottom
\raggedright
\setlength{\tabcolsep}{0in}
\titleformat{\section}{\vspace{-2pt}\scshape\raggedright\large}{}{0em}{}[\color{black}\titlerule\vspace{-3pt}]
\pdfgentounicode=1
\newcommand{\resumeItem}[1]{\item\small{{#1 \vspace{-1pt}}}}
\newcommand{\resumeSubheading}[4]{\vspace{1pt}\item\begin{tabular*}{0.97\textwidth}[t]{l@{\extracolsep{\fill}}r}\textbf{#1} & #2 \\\textit{\small#3} & \textit{\small #4} \\\end{tabular*}\vspace{-4pt}}
\renewcommand\labelitemii{$\vcenter{\hbox{\tiny$\bullet$}}$}
\newcommand{\resumeSubHeadingListStart}{\begin{itemize}[leftmargin=0.15in, label={}]}
\newcommand{\resumeSubHeadingListEnd}{\end{itemize}}
\newcommand{\resumeItemListStart}{\begin{itemize}}
\newcommand{\resumeItemListEnd}{\end{itemize}\vspace{-3pt}}
''';
}