// rustc ./find_projects.rs && ./find_projects

use std::env;
use std::fs;
use std::io;
use std::path::{Path, PathBuf};

const PROJECT_FILES_EXTS: [&str; 10] = [
    "html", "js", "json", "lua", "rb", "ron", "rs", "sh", "toml", "ts",
];

fn main() -> io::Result<()> {
    let root =
        PathBuf::from(env::args().skip(1).next().unwrap_or(String::from(".")));

    let projects = find_projects(root)?;

    for project in projects.projects {
        println!("\"{}\"", project.to_str().unwrap());
    }

    Ok(())
}

#[derive(Default, Debug)]
struct Projects {
    pub projects: Vec<PathBuf>,
    checked_dirs: Vec<PathBuf>,
}

impl Projects {
    pub fn new() -> Self {
        Self::default()
    }

    fn find_in(&mut self, root: PathBuf) -> io::Result<()> {
        use std::fs::FileType;

        for entry in fs::read_dir(&root)? {
            if let Ok(entry) = entry {
                let metadata = entry.metadata()?;

                if metadata.is_dir() {
                    // Check file
                    let path = entry.path();
                    if self.is_project_directory(&path)? {
                        self.projects.push(path);
                    } else {
                        self.find_in(path);
                    }
                } else if metadata.is_file() {
                    // TODO: Ignore?
                }
            }
        }

        Ok(())
    }

    fn is_project_directory(&self, dir: &PathBuf) -> io::Result<bool> {
        Ok(fs::read_dir(dir)?.any(|entry| {
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
                            .map(|ext| PROJECT_FILES_EXTS.contains(&ext))
                            .unwrap_or(false)
                })
                .unwrap_or(false)
        }))
    }
}

fn find_projects(root: PathBuf) -> io::Result<Projects> {
    let mut projects = Projects::new();

    projects.find_in(root)?;

    Ok(projects)
}
