/// Resume Builder ka poora data (saare steps ka).
class ResumeData {
  String fullName;
  String email;
  String phone;
  String location;
  String linkedIn;
  String github;
  String summary;
  List<Experience> experiences;
  List<Education> educations;
  List<Project> projects;
  List<String> skills;
  List<String> achievements;

  ResumeData({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedIn = '',
    this.github = '',
    this.summary = '',
    List<Experience>? experiences,
    List<Education>? educations,
    List<Project>? projects,
    List<String>? skills,
    List<String>? achievements,
  })  : experiences = experiences ?? [],
        educations = educations ?? [],
        projects = projects ?? [],
        skills = skills ?? [],
        achievements = achievements ?? [];
}

class Experience {
  String jobTitle;
  String company;
  String location;
  String duration;
  String description;

  Experience({
    this.jobTitle = '',
    this.company = '',
    this.location = '',
    this.duration = '',
    this.description = '',
  });
}

class Education {
  String degree;
  String institution;
  String location;
  String year;
  String coursework;

  Education({
    this.degree = '',
    this.institution = '',
    this.location = '',
    this.year = '',
    this.coursework = '',
  });
}

class Project {
  String name;
  String techStack;
  String year;
  String description;

  Project({
    this.name = '',
    this.techStack = '',
    this.year = '',
    this.description = '',
  });
}