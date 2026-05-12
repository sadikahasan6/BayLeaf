document.addEventListener('DOMContentLoaded', () => {
    const links = document.querySelectorAll('.sidebar-link');
    const sections = document.querySelectorAll('section');

    function changeActiveLink() {
        let index = sections.length;

        // Determine which section is currently in view
        while(--index && window.scrollY + 100 < sections[index].offsetTop) {}
        
        links.forEach((link) => link.classList.remove('active'));
        links[index].classList.add('active');
    }

    // Update active link on scroll
    window.addEventListener('scroll', changeActiveLink);
    
    // Smooth scroll for sidebar links
    links.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const targetId = link.getAttribute('href');
            document.querySelector(targetId).scrollIntoView({
                behavior: 'smooth'
            });
        });
    });
});