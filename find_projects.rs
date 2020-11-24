use std::env;
use std::fs;
use std::path::PathBuf;

const PROJECT_FILES_EXTS: [&str; 10] = [
    "html", "js", "json", "lua", "rb", "ron", "rs", "sh", "toml", "ts",
];

fn main() {
    let root =
        PathBuf::from(env::args().skip(1).next().unwrap_or(String::from(".")));

    let projects = find_projects(root);

    for project in projects.projects {
        println!("{}", project.to_str().unwrap());
    }
}

#[derive(Default, Debug)]
struct Projects {
    pub projects: Vec<PathBuf>,
}

impl Projects {
    pub fn new() -> Self {
        Self::default()
    }

    fn find_in(&mut self, root: PathBuf) {
        match fs::read_dir(&root) {
            Ok(read_dir) => {
                read_dir.into_iter().for_each(|entry| {
                    if let Ok(entry) = entry {
                        match entry.metadata() {
                            Ok(metadata) => {
                                if metadata.is_dir() {
                                    let path = entry.path();
                                    if self.is_project_directory(&path) {
                                        self.projects.push(path);
                                    } else {
                                        self.find_in(path);
                                    }
                                }
                            }
                            Err(err) => {
                                eprintln!("{}", err);
                            }
                        }
                    }
                });
            }
            Err(err) => {
                eprintln!("{}", err);
            }
        }
    }

    fn is_project_directory(&self, dir: &PathBuf) -> bool {
        fs::read_dir(dir)
            .map_err(|err| {
                eprintln!("{}", err);
                false
            })
            .map(|dir| {
                dir.into_iter().any(|entry| {
                    entry
                        .map(|entry| {
                            entry
                                .metadata()
                                .ok()
                                .map(|meta| meta.is_file())
                                .unwrap_or(false)
                                && entry
                                    .file_name()
                                    .to_str()
                                    .unwrap()
                                    .rsplit('.')
                                    .next()
                                    .map(|ext| {
                                        PROJECT_FILES_EXTS.contains(&ext)
                                    })
                                    .unwrap_or(false)
                        })
                        .unwrap_or(false)
                })
            })
            .unwrap_or(false)
    }
}

fn find_projects(root: PathBuf) -> Projects {
    let mut projects = Projects::new();
    projects.find_in(root);
    projects
}
